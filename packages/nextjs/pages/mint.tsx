import { useEffect, useState } from "react";
import type { NextPage } from "next";
import { useAccount } from "wagmi";
import { MetaHeader } from "~~/components/MetaHeader";
import { Spinner } from "~~/components/assets/Spinner";
import { RainbowKitCustomConnectButton } from "~~/components/scaffold-eth";
import { Address } from "~~/components/scaffold-eth";
import { AddressInput } from "~~/components/scaffold-eth/Input";
import { useScaffoldContract, useScaffoldContractRead, useScaffoldContractWrite } from "~~/hooks/scaffold-eth";
import { notification } from "~~/utils/scaffold-eth";

export interface Collectible {
  id: number;
  uri: string;
  owner: string;
}

export const NFTCard = ({ nft }: { nft: Collectible }) => {
  const [transferToAddress, setTransferToAddress] = useState("");

  const { writeAsync: transferNFT } = useScaffoldContractWrite({
    contractName: "Foldable",
    functionName: "transferFrom",
    args: [nft.owner, transferToAddress, BigInt(nft.id.toString())],
  });

  const handleTransfer = async () => {
    const loadingNotification = notification.loading("Transferring NFT ...");
    try {
      await transferNFT();
      notification.remove(loadingNotification);
      notification.success("NFT Transferred!");
    } catch (error) {
      notification.remove(loadingNotification);
      console.error(error);
    }
  };

  return (
    <div className="card card-compact bg-base-100 shadow-lg sm:min-w-[300px] shadow-secondary">
      <figure className="relative">
        {/* eslint-disable-next-line  */}
        <img src={nft.image} alt="NFT Image" className="h-full min-w-full" />
        <figcaption className="glass absolute bottom-4 left-4 p-1.5 w-25 rounded-xl">
          <span className="text-white "># {nft.id}</span>
        </figcaption>
      </figure>
      <div className="card-body space-y-1">
        <div className="flex items-center justify-center">
          <p className="text-xl p-0 m-0 font-semibold">{nft.name}</p>
          <div className="flex flex-wrap space-x-2 mt-1">
            {nft.attributes?.map((attr, index) => (
              <span key={index} className="badge badge-primary py-3">
                {attr.value}
              </span>
            ))}
          </div>
        </div>
        <div className="flex flex-col justify-center mt-1">
          <p className="my-0 text-lg">{nft.description}</p>
        </div>
        <div className="flex space-x-3 mt-1 items-center">
          <span className="text-lg font-semibold">Owner : </span>
          <Address address={nft.owner} />
        </div>
        <div className="flex flex-col my-2 space-y-1">
          <span className="text-lg font-semibold mb-1">Transfer To: </span>
          <AddressInput
            value={transferToAddress}
            placeholder="receiver address"
            onChange={newValue => setTransferToAddress(newValue)}
          />
        </div>
        <div className="card-actions justify-end">
          <button className="btn btn-secondary btn-md px-8 tracking-wide" onClick={() => handleTransfer()}>
            Send
          </button>
        </div>
      </div>
    </div>
  );
};

const Mint: NextPage = () => {
  const { address: connectedAddress, isConnected, isConnecting } = useAccount();
  const [myAllCollectibles, setMyAllCollectibles] = useState<Collectible[]>([]);
  const [allCollectiblesLoading, setAllCollectiblesLoading] = useState(false);

  const { writeAsync: mintItem } = useScaffoldContractWrite({
    contractName: "Foldable",
    functionName: "mintItem",
  });

  const handleMintItem = async () => {
    const loadingNotification = notification.loading("Minting NFT ...");
    try {
      await mintItem();
      notification.remove(loadingNotification);
      notification.success("NFT Successfully Minted!");
    } catch (error) {
      notification.remove(loadingNotification);
      console.error(error);
    }
  };

  const { data: foldableContract } = useScaffoldContract({
    contractName: "Foldable",
  });

  const { data: balance } = useScaffoldContractRead({
    contractName: "Foldable",
    functionName: "balanceOf",
    args: [connectedAddress],
    watch: true,
  });

  useEffect(() => {
    const updateMyCollectibles = async (): Promise<void> => {
      if (balance === undefined || foldableContract === undefined || connectedAddress === undefined) return;

      console.log("Something");
      setAllCollectiblesLoading(true);
      const collectibleUpdate: Collectible[] = [];
      const myBalance = parseInt(balance.toString());
      for (let tokenIndex = 0; tokenIndex < myBalance; tokenIndex++) {
        try {
          const tokenId = await foldableContract.read.tokenOfOwnerByIndex([
            connectedAddress,
            BigInt(tokenIndex.toString()),
          ]);
          const tokenURI = await foldableContract.read.tokenURI([tokenId]);
          const jsonManifestString = atob(tokenURI.substring(29));
          console.log("jsonManifestString", jsonManifestString);

          try {
            const jsonManifest = JSON.parse(jsonManifestString);
            collectibleUpdate.push({
              id: parseInt(tokenId.toString()),
              uri: tokenURI,
              owner: connectedAddress,
              ...jsonManifest,
            });
          } catch (e) {
            console.log(e);
          }
        } catch (e) {
          notification.error("Error fetching all collectibles");
          setAllCollectiblesLoading(false);
          console.log(e);
        }
      }
      collectibleUpdate.sort((a, b) => a.id - b.id);
      setMyAllCollectibles(collectibleUpdate);
      setAllCollectiblesLoading(false);
    };

    updateMyCollectibles();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [connectedAddress, balance]);

  return (
    <>
      <MetaHeader title="Mint Foldable NFTs!" description="Mint and view your Foldable NFTs here." />
      <div className="flex items-center flex-col flex-shrink pt-10">
        <div className="px-5">
          <h1 className="text-center mb-8">
            <span className="block text-6xl font-bold">Mint Your Folds!</span>
          </h1>
        </div>
        <div>
          {!isConnected || isConnecting ? (
            <RainbowKitCustomConnectButton />
          ) : (
            <button className="btn btn-secondary" onClick={handleMintItem}>
              Mint NFT
            </button>
          )}
        </div>
      </div>

      <div className="flex-grow bg-base-300 w-full mt-16 px-8 py-12">
        {allCollectiblesLoading ? (
          <div className="flex justify-center items-center mt-10">
            <Spinner width="75" height="75" />
          </div>
        ) : myAllCollectibles.length === 0 ? (
          <div className="flex justify-center items-center mt-10">
            <div className="text-2xl text-primary-content">No NFTs Found</div>
          </div>
        ) : (
          <div className="flex flex-wrap gap-4 my-8 px-5 justify-center">
            {myAllCollectibles.map(item => (
              <NFTCard nft={item} key={item.id} />
            ))}
          </div>
        )}
      </div>
    </>
  );
};

export default Mint;
