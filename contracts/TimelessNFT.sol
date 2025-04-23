// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

// import "./ERC721.sol";
// import "./ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TimelessNFT is ERC721Enumerable, Ownable {
    // ye token id generate krne k liye important h. Strings library integer ko string me convert kr degi. hum jha pr bhi uint256 likh kr initialise krege vha pr integer se string convert ho jaiye gi value.
    using Strings for uint256;
    // ye mapping sbhi url ki info hold krti h jo is platform pr mint hoge.
    mapping(string => uint8) existingURIs;
    // is mapping ki help se hum token id k basics pr us k owner ki info fetch krege.
    mapping(uint256 => address) public holderOf;

    // ye sbhi state variables h kyoki ye function k bahar declare kiye gye h aur state variables directly blockchain me store hote h. Yadi hame inko function k andar use krna h toh memory keyword ko use krna hoga.
    // ye artist ka address store krega => artist is solidity contract ka creator h.
    address public artist;
    uint256 public royalityFee;
    uint256 public supply = 0;
    uint256 public totalTx = 0;
    // isme cost of minting store hogi.
    uint256 public cost = 0.01 ether;

    // jab bhi nft mint hogi ya transfer hogi toh ye event trigger hoga.
    event Sale(
        uint256 id,
        address indexed owner,
        uint256 cost,
        string metadataURI,
        uint256 timestamp
    );

    // TransactionStruct ek structure data type bna diya h jisme NFT k related id, owner, cost, title, description, metadataURI, timestamp ek hi datatype me store ho jaiye ge.
    struct TransactionStruct {
        uint256 id;
        address owner;
        uint256 cost;
        string title;
        string description;
        string metadataURI;
        uint256 timestamp;
    }

    // transactions array me jitni bhi NFT ki transactions ho rhi h unki info store hogi.
    TransactionStruct[] transactions;
    // minted array me jitni bhi NFT mint ho rhi h unki info store ho rhi h.
    TransactionStruct[] minted;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _royalityFee,
        address _artist
    )   ERC721(_name, _symbol) {
            royalityFee = _royalityFee;
            artist = _artist;
    }

    // is function ki help se NFT ko mint krege.
    function payToMint( string memory title, string memory description, string memory metadataURI, uint256 salesPrice ) external payable{
        // yadi user ne jo amount bheji h vo cost se kam h toh hum error return krege.
        // msg.value ki value cost se jyada honi chaiye yadi kam hogi toh error shoe hoga. 
        require(msg.value >= cost, "Ether too low for minting!");
        // yadi NFT already minted h toh bhi error return krdege.
        // user ne jo metadataURI bheji h yadi vo existingURIs k map me exist nhi krti h toh error return krege.
        // existingURIs[metadataURI] 0 k equal hoga toh thik h, yadi equal nhi hoga toh error return hoga.
        require(existingURIs[metadataURI] == 0, "This NFT is already minted!");

        // user ne NFT mint krne k liye jo amount bheji h usme se royality lege aur us royality ko is contract k developer k address me bhej dege aur baki bachi hui amount ko owner k address me bhej dege.
        uint256 royality = (msg.value * royalityFee) / 100;
        payTo(artist, royality);
        payTo(owner(), (msg.value - royality));

        // supply variable ko increment kr dege aur ushe us minted NFT ki id me store krdege.
        // hum har ek nft k liye ek unique id rkhege isliye jab bhi nft mint ho rhi h toh supply ko increment kr k nft k sath attach kr dege.
        supply++;

        // minted array me push krde us nft ki info ko.
        minted.push(
        TransactionStruct(
                supply,
                msg.sender,
                salesPrice,
                title,
                description,
                metadataURI,
                block.timestamp
            )
        );

        // sale event ko trigger krege aur usme jo variables h unme ye value assign kr dege.
        emit Sale(
            supply,
            msg.sender,
            msg.value,
            metadataURI,
            block.timestamp
        );

// ye function basically ERC721 standard k according hamari nft ko blockchain pr show kr deta h jis se Wallets aur NFT explorers(openSea etc) hamari NFT ko show krege kyoki inka backend keval standard ERC721 mappings read krta h.
// ye function ERC721 se liya gya h. ye ERC721 ki standard mappings ko update kr deta h. Jab koi dApp (like OpenSea, MetaMask, Zora, etc.) check karega ki tokenId kiski ownership mein hai, toh wo ERC721.ownerOf(tokenId) function call karega.
        _safeMint(msg.sender, supply);
//         With _safeMint()	Without _safeMint()
// ERC721 token is created (ownerOf, balanceOf work)	No actual token in ERC721 sense
// NFT shows in wallets, marketplaces	Invisible to marketplaces
// OpenSea can read metadata and show NFT	OpenSea sees nothing
// ownerOf(tokenId) → returns address	ownerOf(tokenId) → reverts or fails
// NFT is tradeable	Not tradeable through standard tools

        // existingURIs map me us metadataURI k related value ko 1 krdege. iski help se hum check kr skte h ki koi user dobara us same nft ko mint toh nhi kr rha h.
        existingURIs[metadataURI] = 1;

        // holderOf map me NFT ki id k corresponding me jo user NFT mint kr rha h uska address daal dege.
        holderOf[supply] = msg.sender;
    }

    // is function ki help se NFT ko buy kr skta h user.
    function payToBuy(uint256 id) external payable {
        // yadi user ne jo value bheji h vo minted nft ki value se kam h toh error return kr dege.
        require(msg.value >= minted[id - 1].cost, "Ether too low for purchase!");
        // yadi user minted nft ka owner nhi h toh bhi error return kr dege.
        require(msg.sender != minted[id - 1].owner, "Operation Not Allowed!");

        // royality fee calculate krege aur artist ko pay kr dege.
        uint256 royality = (msg.value * royalityFee) / 100;
        payTo(artist, royality);

        // NFT k owner ko user ne jo amount bheji h nft buy krne k liye usme se royality hta kr bachi hui amount de dege.
        payTo(minted[id - 1].owner, (msg.value - royality));

        // transaction vali array me NFT ki id iski help se store krege.
        totalTx++;

        // transactions vali array me transaction jo hui h uski details push krege. 
        transactions.push(
            TransactionStruct(
                totalTx,
                msg.sender,
                msg.value,
                minted[id - 1].title,
                minted[id - 1].description,
                minted[id - 1].metadataURI,
                // iski help se NFT jis time pr mint hui h vo time aa jaiye ga.
                block.timestamp
            )
        );

        // Sale event ko trigger kr k usme value change kr dege. 
        emit Sale(
            totalTx,
            msg.sender,
            msg.value,
            minted[id - 1].metadataURI,
            block.timestamp
        );

        // minted NFT k owner me jisne ushe buy kiya h uska address daal dege.
        minted[id - 1].owner = msg.sender;
    }

    // is function ki help se hum nft ka price change kr skte h.
    function changePrice(uint256 id, uint256 newPrice) external returns (bool) {
        require(newPrice > 0 ether, "Ether too low!");
        require(msg.sender == minted[id - 1].owner, "Operation Not Allowed!");

        minted[id - 1].cost = newPrice;
        return true;
    }

    // is function ki help se hum kisi address pr ether send kr skte h.
    function payTo(address to, uint256 amount) internal {
        // payable(to) => iski help se hum jiske paas ether bhej rhe h us k address ko payable bna dege.
        // .call method ki help se hum ether(jo amount h) ushe send kr skte h.
        // ("") => iska matlab h ki koi bhi data response me nhi jaiye ga.
        // payable(to).call{value: amount}("") => iska matlab h ki receiver k address ko payable bnaya h aur call method ki help se hum ether transfer kr rhe h uske saath koi data send nhi kr rhe.
        // ye response me true ya false return krega ki transaction successful hua h ya nhi.
        (bool success, ) = payable(to).call{value: amount}("");

        // yadi transaction successful nhi hua h toh fail ho jaiye ga ye function.
        require(success);
    }

    // is function ki help se hum sbhi blockchain pr minted NFT ko le skte h.
    function getAllNFTs() external view returns (TransactionStruct[] memory) {
        return minted;
    }

    // is function ki help se hum kisi particular NFT ko le skte h.
    function getNFT(uint256 id) external view returns (TransactionStruct memory){
        return minted[id - 1];
    }

    // is function ki help se hum sbhi transactions ko le skte h.
    function getAllTransactions() external view returns (TransactionStruct[] memory) {
        return transactions;
    }
}