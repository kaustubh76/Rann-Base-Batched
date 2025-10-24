// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {KurukshetraOptimized} from "./KurukshetraOptimized.sol";
import {IYodhaNFT} from "../Interfaces/IYodhaNFT.sol";

/**
 * @title KurukshetraFactoryOptimized
 * @author Rann Protocol
 * @notice Factory for creating optimized Kurukshetra battle arenas with custom VRF
 */
contract KurukshetraFactoryOptimized {
    error KurukshetraFactory__NotDAO();
    error KurukshetraFactory__InvalidAddress();
    error KurukshetraFactory__InvalidBetAmount();
    error KurukshetraFactory__InvalidCostToInfluence();
    error KurukshetraFactory__InvalidCostToDefluence();
    error KurukshetraFactory__NotArena();

    event NewArenaCreated(
        address indexed arenaAddress,
        IYodhaNFT.Ranking indexed ranking,
        uint256 costToInfluence,
        uint256 costToDefluence,
        uint256 betAmount
    );

    address[] private s_arenas;
    mapping(address => bool) private s_isArena;
    mapping(address => IYodhaNFT.Ranking) private s_arenaRankings;
    address private immutable i_rannTokenAddress;
    address private immutable i_nearAiPublicKey;
    address private immutable i_vrfCoordinator;
    address private immutable i_yodhaNFTCollection;
    address private immutable i_dao;

    modifier onlyDAO() {
        if (msg.sender != i_dao) {
            revert KurukshetraFactory__NotDAO();
        }
        _;
    }

    modifier onlyArenas() {
        if (!s_isArena[msg.sender]) {
            revert KurukshetraFactory__NotArena();
        }
        _;
    }

    constructor(
        address _rannTokenAddress,
        address _yodhaNFTCollection,
        address _nearAiPublicKey,
        address _vrfCoordinator
    ) {
        if (
            _rannTokenAddress == address(0) ||
            _yodhaNFTCollection == address(0) ||
            _nearAiPublicKey == address(0) ||
            _vrfCoordinator == address(0)
        ) {
            revert KurukshetraFactory__InvalidAddress();
        }

        i_dao = msg.sender;
        i_rannTokenAddress = _rannTokenAddress;
        i_yodhaNFTCollection = _yodhaNFTCollection;
        i_nearAiPublicKey = _nearAiPublicKey;
        i_vrfCoordinator = _vrfCoordinator;
    }

    /**
     * @notice Create a new optimized Kurukshetra arena
     * @param _costToInfluence Cost to influence a Yodha
     * @param _costToDefluence Cost to defluence a Yodha
     * @param _betAmount Bet amount for the arena
     * @param _ranking Ranking category for the arena
     * @return Address of the newly created arena
     */
    function makeNewArena(
        uint256 _costToInfluence,
        uint256 _costToDefluence,
        uint256 _betAmount,
        IYodhaNFT.Ranking _ranking
    ) external onlyDAO returns (address) {
        if (_betAmount == 0) {
            revert KurukshetraFactory__InvalidBetAmount();
        }
        if (_costToInfluence == 0) {
            revert KurukshetraFactory__InvalidCostToInfluence();
        }
        if (_costToDefluence == 0) {
            revert KurukshetraFactory__InvalidCostToDefluence();
        }

        KurukshetraOptimized newArena = new KurukshetraOptimized(
            i_vrfCoordinator,
            i_rannTokenAddress,
            i_yodhaNFTCollection,
            i_nearAiPublicKey,
            _ranking,
            _betAmount,
            _costToInfluence,
            _costToDefluence,
            address(this)
        );

        address arenaAddress = address(newArena);
        s_arenas.push(arenaAddress);
        s_isArena[arenaAddress] = true;
        s_arenaRankings[arenaAddress] = _ranking;

        // Note: VRF coordinator owner needs to authorize this arena as a consumer

        emit NewArenaCreated(
            arenaAddress,
            _ranking,
            _costToInfluence,
            _costToDefluence,
            _betAmount
        );

        return arenaAddress;
    }

    /**
     * @notice Update winnings for a Yodha (called by arenas)
     * @param _yodhaNFTId Token ID of the Yodha
     * @param _amount Amount to add to winnings
     */
    function updateWinnings(uint256 _yodhaNFTId, uint256 _amount) external onlyArenas {
        IYodhaNFT(i_yodhaNFTCollection).increaseWinnings(_yodhaNFTId, _amount);
    }

    // View functions
    function getArenas() external view returns (address[] memory) {
        return s_arenas;
    }

    function getArenaRanking(address _arena) external view returns (IYodhaNFT.Ranking) {
        return s_arenaRankings[_arena];
    }

    function isArenaAddress(address _arena) external view returns (bool) {
        return s_isArena[_arena];
    }

    function getRannTokenAddress() external view returns (address) {
        return i_rannTokenAddress;
    }

    function getVRFCoordinator() external view returns (address) {
        return i_vrfCoordinator;
    }

    function getYodhaNFTCollection() external view returns (address) {
        return i_yodhaNFTCollection;
    }

    function getDAO() external view returns (address) {
        return i_dao;
    }
}
