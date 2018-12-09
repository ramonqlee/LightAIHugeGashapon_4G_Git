--- 模块功能：testAdc
-- @module test
-- @author openLuat
-- @license MIT
-- @copyright openLuat
-- @release 2018.1.3
-- @describe 每隔5s发送0x01,0x20

require "clib"
require "utils"
require "ntp"
require "Consts"
require "LogUtil"
require "UartMgr"
require "update"
require "Config"
require "Task"
require "Deliver"
require "MQTTManager"


local TAG="Entry"
local timerId=nil
local timedTaskId = nil
local mqttNetConnectCount=0

function startTimedTask()
    if timedTaskId and sys.timerIsActive(timedTaskId) then
        LogUtil.d(TAG," startTimedTask running,return")
        return
    end

    timedTaskId = sys.timerLoopStart(function()
            if MQTTManager.hasMessage() then
            	return
            end

            -- 检查下mqtt的状态，如果没运行，则重启下
            mqttChecker()
            checkTask()
            checkUpdate()
            
        end,Consts.TIMED_TASK_INTERVAL_MS)
end

function mqttChecker()
    -- body
    if not MQTTManager.isConnected() then
        mqttNetConnectCount = mqttNetConnectCount +1
    else
        mqttNetConnectCount = 0
    end

    if mqttNetConnectCount >= Consts.MIN_MQTT_REBOOT_COUNT then
        sys.restart("mqttFail")
    end
end

-- 自动升级检测
function checkUpdate()
    if Deliver.isDelivering() then
        LogUtil.d(TAG,TAG.." Deliver.isDelivering,delay update")
        return
    end

    update.request() -- 检测是否有更新包
end


--任务检测
function checkTask()
    if Deliver.isDelivering() then
        LogUtil.d(TAG,TAG.." Deliver.isDelivering,delay taskCheck")
        return
    end

    Task.getTask()               -- 检测是否有新任务 
end


function run()
	startTimedTask()
	
    rtos.make_dir(Consts.USER_DIR)--make sure directory exist

	-- 启动一个延时定时器, 获取板子id
	LogUtil.d(TAG,"app start now")
	timerId = sys.timerStart(function()
		LogUtil.d(TAG,"start to retrieve slaves")
		if timerId and sys.timerIsActive(timerId) then
			sys.timerStop(timerId)
			timerId = nil
		end

		--首先初始化本地环境，然后成功后，启动mqtt
		UartMgr.init(Consts.UART_ID,Consts.baudRate)
		
		sys.taskInit(MQTTManager.startmqtt)

	end,2*1000)

end


sys.taskInit(run)
ntp.timeSync()




           