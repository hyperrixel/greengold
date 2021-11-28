// SPDX-License-Identifier: Copyright
pragma solidity >=0.7.0 <0.9.0;

contract GreenGold {

    /**
     * Smart Contract Constructor
     * --------------------------
     *
     * @param sentence A sentence to increase contract's security
     */
    constructor(string memory sentence) payable {

        rootUser = payable(msg.sender);
        rootKey = keccak256(abi.encodePacked(sentence));

    }

    /**
     * Raw data manipulation of parentDevices
     * ======================================
     *
     * CREATE
     * ------
     */

    function addParentDevice(string calldata message,
                             string calldata name, uint8 status,
                             uint8 consumptionType,
                             uint defaultCPU) onlyAdmin(message)
                             external {
        
        parentDevices.push(ParentDevice(name, status,
                           consumptionType, defaultCPU));

    }

    /**
     * READ
     * ----
     */

    function getParentDeviceById(uint id)
                                    onlyExistingParentDevice(id)
                                    external view returns
                                    (ParentDevice memory) {

        require(id < parentDevices.length, 'Invalid device Id.');
        return parentDevices[id];

    }

    function getParentDevices() external view
                                returns (ParentDevice[] memory) {

        return parentDevices;

    }

    /**
     * UPDATE
     * ------
     */

    function changeParentDevice(string calldata message, uint id,
                                string calldata name, uint8 status,
                                uint8 consumptionType, uint defaultCPU)
                                onlyAdmin(message)
                                onlyExistingParentDevice(id) external {

        parentDevices[id].name = name;
        parentDevices[id].status = status;
        parentDevices[id].consumptionType = consumptionType;
        parentDevices[id].defaultCPU = defaultCPU;

    }

    /**
     * DELETE
     * ------
     */

    // NOT AVAILABLE.

    /**
     * Raw data manipulation of userDevices
     * ====================================
     *
     * CREATE
     * ------
     */

    function addUserDevice(string calldata customName,
                           uint customCPU,
                           uint parentDeviceId)
                           onlyExistingParentDevice(parentDeviceId)
                           external {
        
        userDevices[msg.sender].push(UserDevice(customName,
                                                customCPU,
                                                parentDeviceId));

    }

    /**
     * READ
     * ----
     */

    function getUserDevices() external view
                              returns (UserDevice[] memory) {

        return userDevices[msg.sender];

    }

    /**
     * UPDATE
     * ------
     */

    function changeUserDevice(uint id,
                              string calldata customName,
                              uint customCPU,
                              uint parentDeviceId)
                              onlyExistingUserDevice(id)
                              onlyExistingParentDevice(parentDeviceId)
                              external {
        
        userDevices[msg.sender][id].customName = customName;
        userDevices[msg.sender][id].customCPU = customCPU;
        userDevices[msg.sender][id].parentDeviceId = parentDeviceId;

    }

    /**
     * DELETE
     * ------
     */

    // NOT AVAILABLE.

    /**
     * Raw data manipulation of timeMeasures
     * =====================================
     *
     * CREATE
     * ------
     */

    function startTimeMeasure(uint userDeviceId)
                             onlyExistingUserDevice(userDeviceId)
                             external {

        timeMeasures[msg.sender].push(TimeMeasure(block.timestamp, 0, userDeviceId));

    }

    /**
     * READ
     * ----
     */

    function getTimeMeasures() external view
                               returns (TimeMeasure[] memory) {

        return timeMeasures[msg.sender];

    }

    /**
     * UPDATE
     * ------
     */

    function stopTimeMeasure(uint measureId)
                             onlyEnoughFee()
                             onlyLivingTimeMeasure(measureId)
                             external payable {
    
        timeMeasures[msg.sender][measureId].stop = block.timestamp;

    }

    /**
     * DELETE
     * ------
     */

    // NOT AVAILABLE.

    /**
     * Raw data manipulation of unitMeasures
     * =====================================
     *
     * CREATE
     * ------
     */

    function addUnitMeasure(uint unitCount, uint userDeviceId)
                            onlyEnoughFee()
                            onlyExistingUserDevice(userDeviceId)
                            external payable {

        unitMeasures[msg.sender].push(UnitMeasure(block.timestamp,
                                                  unitCount,
                                                  userDeviceId));

    }

    /**
     * READ
     * ----
     */

    function getUnitMeasures() external view
                               returns (UnitMeasure[] memory) {

        return unitMeasures[msg.sender];

    }

    /**
     * UPDATE
     * ------
     */

    // NOT AVAILABLE.

    /**
     * DELETE
     * ------
     */

    // NOT AVAILABLE.

    /**
     * MODIFIERS
     * =========
     */

    /**
     * Modifier to optimize code if checking admin credentials
     * -------------------------------------------------------
     *
     * @param sentence Admin credentials
     */
    modifier onlyAdmin(string memory sentence) {

        require(msg.sender == rootUser, 'Authorization required!');
        require(keccak256(abi.encodePacked(sentence)) == rootKey,
                'Authorization key required!');
        _;

    }

    modifier onlyEnoughFee() {

        require(msg.value >= MEASURE_FEE,
                'Action not available without fee.');
        _;

    }

    modifier onlyExistingParentDevice(uint id) {

        require(id < parentDevices.length,
                'Invalid parent device Id.');
        _;

    }

    modifier onlyExistingUserDevice(uint id) {

        require(id < userDevices[msg.sender].length,
                'Invalid user device Id.');
        _;

    }

    modifier onlyLivingTimeMeasure(uint id) {

        require(id < timeMeasures[msg.sender].length,
                'Invalid time measure Id.');
        require(timeMeasures[msg.sender][id].stop == 0,
                'Cannot stop a halted time measure.');
        _;

    }
    

    /**
     * STRUCT DEFINITIONS
     * ==================
     */

    struct ParentDevice {
        string name;
        uint8 status;
        uint16 consumptionType;
        uint defaultCPU;
    }

    struct UserDevice {
        string customName;
        uint customCPU;
        uint parentDeviceId;
    }
    
    struct TimeMeasure {
        uint256 start;
        uint256 stop;
        uint userDeviceId;
    }

    struct UnitMeasure {
        uint256 when;
        uint unitCount;
        uint userDeviceId;
    }

     /**
     * PUBLIC CONSTANTS
     * ================
     */

    uint256 constant public MEASURE_FEE = 100;

   /**
     * STATE VARIABLES
     * ===============
     */

    // Admin credentials
    address payable private rootUser;
    bytes32 private rootKey;

    // Public variables
    ParentDevice[] public parentDevices;
    mapping (address => TimeMeasure[]) public timeMeasures;
    mapping (address => UnitMeasure[]) public unitMeasures;
    mapping (address => UserDevice[]) public userDevices;

}