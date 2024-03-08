import Link from "next/link";
import type { NextPage } from "next";
import { DocumentIcon, SparklesIcon } from "@heroicons/react/24/outline";
import { MetaHeader } from "~~/components/MetaHeader";

const Home: NextPage = () => {
  return (
    <>
      <MetaHeader />
      <div className="flex items-center flex-col flex-grow pt-10">
        <div className="px-5">
          <h1 className="text-center mb-8">
            <span className="block text-2xl mb-2">Welcome to</span>
            <span className="block text-6xl font-bold">Foldable NFT!</span>
          </h1>
          <p className="text-center text-lg">Built using Scaffold-ETH 2</p>
          <p className="text-center text-lg">Get started by minting some basic Fold NFTs!</p>
          <p className="text-center text-lg">Combine two basic folds to mint a new animal Fold NFT!</p>
        </div>

        <div className="flex-grow bg-base-300 w-full mt-16 px-8 py-12">
          <div className="flex justify-center items-center gap-12 flex-col sm:flex-row">
            <div className="flex flex-col bg-base-100 px-20 py-10 text-center items-center max-w-xs rounded-3xl">
              <SparklesIcon className="h-8 w-8 fill-secondary" />
              <p>
                Go mint some folds in the{" "}
                <Link href="/mint" passHref className="link">
                  Mint
                </Link>{" "}
                tab.
              </p>
            </div>
            <div className="flex flex-col bg-base-100 px-20 py-10 text-center items-center max-w-xs rounded-3xl">
              <DocumentIcon className="h-8 w-8 fill-secondary" />
              <p>
                Combine your Fold NFTs in the{" "}
                <Link href="/fold" passHref className="link">
                  Fold
                </Link>{" "}
                tab.
              </p>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default Home;
