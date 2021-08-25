pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IUniswapV2Factory.sol";

contract SMON is ERC20, Ownable {

    uint256 public total = 100000000 * 1e18;

    bool public isInit = false;
    // Limit from PancakeSwap Buy Max End Block...
    uint256 public endBlock;
    bool public swapEnable = false;
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    constructor(address _router, address _BUSD)
        ERC20("StarMon", "SMON")
    public {

      IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);
       // Create a uniswap pair for this new token
      uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
          .createPair(address(this), _BUSD);
      uniswapV2Router = _uniswapV2Router;

      endBlock = block.number + 20 * 60 * 24 * 3;
    }

    function initSupply(address _teamAddr,
                address _marketingAddr,
                address _ecoFundAddr,
                address _partnersAddr,
                address _playToEarnAddr,
                address _nftPoolAddr,
                address _privateSaleAddr) external onlyOwner {
          require(!isInit, "inited");
          isInit = true;
          _mint(_teamAddr, total.mul(20).div(100));
          _mint(_marketingAddr, total.mul(20).div(100));
          _mint(_ecoFundAddr, total.mul(20).div(100));
          _mint(_partnersAddr, total.mul(10).div(100));
          _mint(_playToEarnAddr, total.mul(20).div(100));
          _mint(_nftPoolAddr, total.mul(5).div(100));
          _mint(_privateSaleAddr, total.mul(5).div(100));
    }

    // Extend transfer
    function _transfer(address sender, address recipient, uint256 amount) internal override virtual {
      // when swapEnable is True, The condition will the failure
      if(!swapEnable && sender == uniswapV2Pair && block.number < endBlock){
          revert("The PancakeSwap has no open");
      }

      if(!swapEnable && sender == uniswapV2Pair){
          // Active PancakeSwap Buy
          swapEnable = true;
      }

      super._transfer(sender, recipient, amount);
    }

    // When swapEnable is False, owner can update EndBlock, But swapEnable is True, The Function is invalid
    function setEndBlock(uint256 _endBlock) external onlyOwner{
        require(!swapEnable, "swapEnable is True");
        require(_endBlock > block.number, "endBlock less Than block.number");
        endBlock = _endBlock;
    }
}
