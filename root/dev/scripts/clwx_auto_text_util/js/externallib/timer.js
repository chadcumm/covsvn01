/**
 * @class
 * This class wraps the checkpoint system. It allows developers to make use of the RTMS V4 API.
 * @returns {CheckpointTimer}
 * @constructor
 */
function CheckpointTimer() {
	this.m_checkpointObject = null;
	try {
		this.m_checkpointObject = window.external.DiscernObjectFactory("CHECKPOINT");
	} catch (exe) {
		log.error("Unable to create checkpoint object via window.external.DiscernObjectFactory('CHECKPOINT')");
		return this;
	}
	return this;
}

/**
 * Sets the ClassName parameter on the checkpoint object, if it exists. The class name identifies which class
 * this checkpoint originates from.
 * @param {string} className - The ClassName parameter for the checkpoint object.
 * @returns {CheckpointTimer}
 */
CheckpointTimer.prototype.setClassName = function (className) {
	if (this.m_checkpointObject) {
		this.m_checkpointObject.ClassName = className;
	}
	return this;
};

/**
 * Sets the ProjectName parameter on the checkpoint object. The project name identifies the project that this
 * checkpoint originates from.
 * @param {string} projectName - The ProjectName parameter for the checkpoint object.
 * @returns {CheckpointTimer}
 */
CheckpointTimer.prototype.setProjectName = function (projectName) {
	if (this.m_checkpointObject) {
		this.m_checkpointObject.ProjectName = projectName;
	}
	return this;
};

/**
 * Sets the EventName on the checkpoint object. The event name identifies which event the checkpoint originates
 * from.
 * @param {string} eventName - The EventName for the checkpoint object.
 * @returns {CheckpointTimer}
 */
CheckpointTimer.prototype.setEventName = function (eventName) {
	if (this.m_checkpointObject) {
		this.m_checkpointObject.EventName = eventName;
	}
	return this;
};

/**
 * Sets the SubEventName on the checkpoint object. The sub event name identifies which sub-event the checkpoint
 * originates from.
 * @param {string} subEventName - The SubEventName for the checkpoint object.
 * @returns {CheckpointTimer}
 */
CheckpointTimer.prototype.setSubEventName = function (subEventName) {
	if (this.m_checkpointObject) {
		this.m_checkpointObject.SubEventName = subEventName;
	}
	return this;
};

/**
 * Calls Publish on the checkpoint object. This will publish the checkpoint out to the timer system.
 */
CheckpointTimer.prototype.publish = function () {
	if (this.m_checkpointObject) {
		this.m_checkpointObject.Publish();
	}
};

/**
 * This will add a metadata value to the checkpoint object with the specified key and value.
 * @param {string} key - The key value for the metadata.
 * @param {string} value - The value for the metadata.
 */
CheckpointTimer.prototype.addMetaData = function(key, value) {
	if(this.m_checkpointObject && key && value) {
		try {
			this.m_checkpointObject.MetaData(key) = value;
		} catch (e) {
			log.error("Error adding MetaData [" + key + "] = " + value + "; on CheckpointTimer");
			return this;
		}
	}
	return this;
};

/**
 * @class
 * This class handles the classic use of timers in our system. This version of the timer makes use of the
 * Checkpoint system rather than the traditional Start and Stop methods.
 * @param {string} timerName - The name of the timer. This maps to the original TimerName of the old timer system.
 * @param {string} subTimerName - The name of the sub timer. This maps to the original SubTimerName of the old timer system.
 * @returns {RTMSTimer}
 * @constructor
 */
function RTMSTimer(timerName, subTimerName) {
	this.m_checkpointTimer = new CheckpointTimer();
	this.m_checkpointTimer.setEventName(timerName);
	this.m_checkpointTimer.addMetaData("rtms.legacy.subtimerName", subTimerName);
	return this;
}

/**
 * Adaptor method that simply passes through to the checkpoint object and adds metadata.
 * @param {String} key - the metadata key.
 * @param {String} value - the metadata value.
 */
RTMSTimer.prototype.addMetaData = function(key, value) {
	this.m_checkpointTimer.addMetaData(key, value);
	return this;
};

/**
 * Starts the timer by setting the SubEventName on the checkpoint and calling publish.
 */
RTMSTimer.prototype.start = function() {
	this.checkpoint("Start");
};

/**
 * @deprecated
 * This method has been deprecated. Use RTMSTimer.prototype.start instead.
 * @constructor
 */
RTMSTimer.prototype.Start = function() {
	this.start();
};

/**
 * Stops the timer by setting the SubEventName on the checkpoint and calling publish.
 */
RTMSTimer.prototype.stop = function() {
	this.checkpoint("Stop");
};

/**
 * @deprecated
 * This method has been deprecated. Use RTMSTimer.prototype.stop instead.
 * @constructor
 */
RTMSTimer.prototype.Stop = function() {
	this.stop();
};

/**
 * Fails the timer by setting the SubEventName on the checkpoint and calling publish.
 */
RTMSTimer.prototype.fail = function() {
	this.checkpoint("Fail");
};

/**
 * @deprecated
 * This method has been deprecated. Use RTMSTimer.prototype.fail instead.
 * @constructor
 */
RTMSTimer.prototype.Abort = function() {
	this.fail();
};

/**
 * Publishes a checkpoint for the timer.
 * @param {string} subEventName - The sub event name of the checkpoint.
 */
RTMSTimer.prototype.checkpoint = function(subEventName) {
	this.m_checkpointTimer.setSubEventName(subEventName);
	this.m_checkpointTimer.publish();
};
