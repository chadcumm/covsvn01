import FusionComponentScriptRequest from "FusionComponentScriptRequest"; // eslint-disable-line no-unused-vars

/**
 * getData is a generic implementation of a data retrieval function.
 * @param {FusionComponent} component The FusionComponent needed in order to execute the data request
 * @returns {Promise} The promise used to resolve or reject the data request response
 */
const getData = component => new Promise((resolve, reject) => {
    const scriptRequest = new FusionComponentScriptRequest();
    // TODO: Add you script request name
    scriptRequest.setName("Example Request");
    scriptRequest.setArtifactInfo({
        artifactId: "MPagesFusionCustomComponent",
        functionName: "getData"
    });

    // This MP_RETRIEVE_MOCK_DATA is a mock script that returns mock data so that the component load in an MPage view.
    // Passing in a "F" would make the script return a failure.
    // A "Z" value would make the script return no data and a Z status.
    // TODO: Replace this script name with your real script.
    scriptRequest.setProgramName("MP_RETRIEVE_MOCK_DATA");
    scriptRequest.setParameterArray(
        [
            "^MINE^"
        ]
    );
    scriptRequest.setResponseHandler((reply) => {
        if (reply.getStatus() !== "F") {
            resolve(reply);
        } else {
            reject(reply);
        }
    });
    scriptRequest.setComponent(component);
    scriptRequest.performRequest();
});

export default getData;
