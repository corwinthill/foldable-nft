//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {HexStrings} from "./Libraries.sol";

contract Foldable is ERC721, ERC721Enumerable {

    using Strings for uint256;
    using HexStrings for uint160;

    error InvalidFoldCombination();

    uint256 public tokenId = 0;

    struct FoldableInfo {
        string color;
        uint256 colorInt;
        string foldType;
        uint256 foldInt;
    }

    mapping (uint256 => FoldableInfo) public foldableInfo;

    string[6] public COLOR_ARRAY = ["Red", "Blue", "Yellow", "Green", "Orange", "Purple"];
    string[5] public TYPE_ARRAY = ["Squash Fold", "Triangle Fold", "Rectangle Fold", "Butterfly", "Frog"];

    constructor() public ERC721("Foldable NFT", "FOLD") {
        // Start Folding
    }

    function mintItem() public returns(uint256) {
        uint256 id = tokenId;

        bytes32 predictableRandom = keccak256(abi.encodePacked(blockhash(block.number-1), msg.sender, address(this)));
        bytes32 predictableRandom2 = keccak256(abi.encodePacked(blockhash(block.number-2), msg.sender, address(this)));
        uint256 randColor = uint256(predictableRandom) % 3;  // Pick color 1 thru 3
        uint256 randType = uint256(predictableRandom2) % 3;  // Pick base fold 1 thru 3
        foldableInfo[id] = FoldableInfo({
            color: COLOR_ARRAY[randColor],
            colorInt: randColor,
            foldType: TYPE_ARRAY[randType],
            foldInt: randType
        });

        _mint(msg.sender, id);
        tokenId += 1;
        return id;
    }

    function tokenURI(uint256 id) public view override returns(string memory) {
        _requireOwned(id);

        string memory name = string(abi.encodePacked("Foldable #", id.toString()));
        string memory description = string(abi.encodePacked(
            "This Foldable NFT is a ", foldableInfo[id].color, " ", foldableInfo[id].foldType, "!"));
        string memory image = Base64.encode(bytes(generateSVGofTokenById(id)));

        return
            string(
                abi.encodePacked(
                    'data:application/json;base64,',
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name,
                                '", "description":"',
                                description,
                                '", "attributes": [{"trait_type": "foldable type", "value": "',
                                foldableInfo[id].foldType,
                                '"},{"trait_type": "color", "value": "',
                                foldableInfo[id].color,
                                '"}], "owner":"',
                                (uint160(ownerOf(id))).toHexString(20),
                                '", "image": "',
                                'data:image/svg+xml;base64,',
                                image,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function generateSVGofTokenById(uint256 id) public view returns (string memory) {
        string memory svg = string(abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="100%" height="100%" viewBox="70 120  780 850" preserveAspectRatio="xMinYMin meet" ><rect id="svgEditorBackground" x="0" y="0" width="870" height="1170" style="fill: none; stroke: none;"/>',
            renderTokenById(id),
            '</svg>'
        ));
        return svg;
    }

    function renderTokenById(uint256 id) internal view returns (string memory) {
        uint256 fold = foldableInfo[id].foldInt;

        if (fold == 0) {
            return (string(abi.encodePacked(
                '<polyline style="stroke:', foldableInfo[id].color, ';fill:none;stroke-width:2px" id="e29_polyline" points="217.628,739.735,667.858,746.724,501.143,676.843,584.002,648.891,665.862,747.722,582.005,648.891,655.879,625.93,425.273,540.077,215.631,594.983,370.367,664.863,217.628,739.735,301.485,633.916,368.37,662.867,432.261,598.976,501.143,673.848" transform="matrix(1 0 0 1 -1.99659 -82.8584)"/>',
                '<polyline style="stroke:', foldableInfo[id].color, ';fill:none;stroke-width:2px;stroke-dasharray:4px, 4px" id="e30_polyline" points="215.631,593.985,430.264,596.979,654.881,624.932" transform="matrix(1 0 0 1 -1.99659 -82.8584)"/>'
            )));
        } else if (fold == 1) {
            return (string(abi.encodePacked(
                '<line id="e5_line" x1="238.5921501706" y1="627.9266211604" x2="533.0887372014" y2="406.3054607509" style="stroke:', foldableInfo[id].color, ';fill:none;stroke-width:2px;stroke-dasharray:4px, 4px"/>',
                '<polyline style="stroke:', foldableInfo[id].color, ';fill:none;stroke-width:2px" id="e6_polyline" points="531.092,407.304,524.104,617.944,236.596,628.925,518.114,644.898,516.118,617.944"/>'
            )));
        } else if (fold == 2) {
            return (string(abi.encodePacked(
                '<line id="e9_line" x1="292.4998524115761" y1="388.3363342285156" x2="589.9909107611854" y2="387.3378601074219" style="stroke:', foldableInfo[id].color, ';fill:none;stroke-width:2px;stroke-dasharray:4px, 4px"/>',
                '<polyline style="stroke:', foldableInfo[id].color, ';fill:none;stroke-width:2px" id="e10_polyline" points="290.503,387.338,262.551,499.147,570.026,496.152,588.993,388.336,592.986,657.875,292.5,656.877,289.505,498.148"/>'
            )));
        } else if (fold == 3) {
            return (string(abi.encodePacked(
                '<polyline style="stroke:', foldableInfo[id].color, ';fill:none;stroke-width:2px" id="e11_polyline" points="213.635,337.423,332.432,461.212,447.236,469.198,523.106,399.317,525.102,217.628,442.244,338.422,407.304,331.433,386.34,358.387,212.637,336.425,332.432,461.212,353.396,462.21,411.297,530.094,462.21,543.072,437.253,468.2,446.237,469.198,458.217,459.215,478.183,536.084,519.113,496.152,511.126,409.3,448.234,468.2,442.244,338.422,406.305,331.433,386.34,357.389,445.239,464.206" transform="matrix(1 0 0 1 49.9147 127.782)"/>',
                '<line id="e12_line" x1="408.302" y1="332.432" x2="449.232" y2="466.202" style="stroke:', foldableInfo[id].color, ';fill:none;stroke-width:2px;stroke-dasharray:4px, 4px" transform="matrix(1 0 0 1 49.9147 127.782)"/>'
            )));
        } else if (fold == 4) {
            return (string(abi.encodePacked(
                '<polyline style="stroke:', foldableInfo[id].color, ';fill:none;stroke-width:2px" id="e13_polyline" points="385.341,367.372,331.433,464.206,350.401,529.096,518.114,477.184,495.154,408.302,385.341,366.374,480.179,402.312,496.152,351.399,515.119,411.297,503.14,430.264,519.113,477.184,508.131,480.179,516.118,502.142,348.404,552.056,506.135,505.137,544.07,520.111,491.16,535.085,471.195,515.119,349.403,552.056,333.43,581.007,391.331,563.038,396.323,537.082,349.403,551.058,339.42,518.114,348.404,526.101,335.427,477.184,310.469,473.191,291.502,414.292,343.413,439.249" transform="matrix(1 0 0 1 7.98635 46.9198)"/>'
            )));
        }
    }

    function foldAndMint(uint256 id1, uint256 id2) public returns (uint256) {
        //check to see if tokens exist
        address owner1 = _requireOwned(id1);
        address owner2 = _requireOwned(id2);

        // check to see if user is authorized to burn these tokens
        _checkAuthorized(owner1, msg.sender, id1);
        _checkAuthorized(owner2, msg.sender, id2);

        // check to see if contract is authorized to burn these tokens
        _checkAuthorized(owner1, address(this), id1);
        _checkAuthorized(owner2, address(this), id2);

        uint256 newId = tokenId;

        uint256 type1 = foldableInfo[id1].foldInt;
        uint256 type2 = foldableInfo[id2].foldInt;
        uint256 newType;

        if ((type1 == 0 && type2 == 1) || (type1 == 1 && type2 == 0)) {
            newType = 3;
        } else if ((type1 == 0 && type2 == 2) || (type1 == 2 && type2 == 0)) {
            newType = 4;
        } else {
            revert InvalidFoldCombination();
        }

        uint256 color1 = foldableInfo[id1].colorInt;
        uint256 color2 = foldableInfo[id2].colorInt;
        uint256 newColor;

        if ((color1 == 0 && color2 == 1) || (color1 == 1 && color2 == 0)) {
            newColor = 5;
        } else if ((color1 == 0 && color2 == 2) || (color1 == 2 && color2 == 0)) {
            newColor = 4;
        } else if ((color1 == 1 && color2 == 2) || (color1 == 2 && color2 == 1)) {
            newColor = 3;
        } else if (color1 == color2) {
            newColor = color1;
        }

        foldableInfo[newId] = FoldableInfo({
            color: COLOR_ARRAY[newColor],
            colorInt: newColor,
            foldType: TYPE_ARRAY[newType],
            foldInt: newType
        });

        _mint(msg.sender, newId);
        _burn(id1);
        _burn(id2);
        
        tokenId += 1;
        return newId;
    }

    function returnThisAddress() public view returns(address) {
        return address(this);
    }

    // Overrides required by solidity

    function _increaseBalance(address account, uint128 amount) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, amount);
    }

    function _update(address to, uint256 theTokenId, address auth) internal override(ERC721, ERC721Enumerable) returns (address) {
        return super._update(to, theTokenId, auth);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    
}