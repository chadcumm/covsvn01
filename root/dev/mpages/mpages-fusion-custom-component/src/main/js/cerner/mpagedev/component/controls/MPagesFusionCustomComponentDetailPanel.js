import { composite, UIComponent } from "MPageFusion";
import { EVENTS } from "../constants/MPagesFusionCustomComponentConstants";

const {
    detailPanel: {
        DetailPanel,
        DetailPanelTitle,
        DetailPanelData
    }
} = composite;

/**
 * This is an example function used to create a small portion of the overall detail
 * panel configuration.  It shows how you can isolate logic into small functions to make
 * code easier to test and also consume.
 * @param {object} resultObj The result object we will use to create the 'Value' section
 * of our example detail panel.
 * @returns {object} The detail panel data section configuration for the 'Value' section
 * of the detail panel
 */
const createActivityDetailsSection = (resultObj) => {
    return [
        {
            id: "activityDetailSection",
            rows: [
                [
                    {
                        label: "Days of Week",
                        text: resultObj.DAYS_PER_WEEK,
                        span: 6
                    },
                    {
                        label: "Activity Level",
                        text: resultObj.ACTIVITY_LEVEL,
                        span: 6
                    },
                    {
                        label: "Total time spent",
                        text: resultObj.DURATION,
                        span: 6
                    },
                    {
                        label: "Total Calories Burnt",
                        text: resultObj.WEEKLY_DATA.reduce((previousValue, element) =>
                            Number(previousValue) + Number(element.CALORIES_BURNT), 0)
                    }
                ]
            ]
        }
    ];
};

/**
 * This is an example function used to create a small portion of the overall detail
 * panel configuration.  It shows how you can isolate logic into small functions to make
 * code easier to test and also consume.
 * @param {object} resultObj The result object we will use to create the 'Person' section
 * of our example detail panel.
 * @returns {object} The detail panel data section configuration for the 'Person' section
 * of the detail panel
 */
const createCaloriesBurntSection = (resultObj) => {
    return [
        {
            id: "caloriesBurntSection",
            rows: [
                [
                    {
                        label: "Calories Burnt",
                        text: `${resultObj.CALORIES_BURNT} calories`,
                        span: 12
                    }
                ]
            ]
        }
    ];
};

/**
 * The MPagesFusionCustomComponentDetailPanel class.
 * @class MPagesFusionCustomComponentDetailPanel
 */

export default class MPagesFusionCustomComponentDetailPanel extends UIComponent {
    /**
     * @inheritDoc
     */
    initialProps() {
        return {
            result: null,
            unloadRequestEventName: EVENTS.DETAIL_PANEL.UNLOAD,
        };
    }

    /**
     * @inheritDoc
     */
    propChangeHandlers() {
        return {
            result: (resultObj) => {
                const panel = this.getChild("detailPanel");
                const title = panel.getChild("titleContent");
                const body = panel.getChild("bodyContent");
                title.setProp("title", "Activity Details");
                if (resultObj.ACTIVITY_NAME) {
                    body.setProp("sections", createActivityDetailsSection(resultObj));
                }
                if (resultObj.CALORIES_BURNT >= 0) {
                    body.setProp("sections", createCaloriesBurntSection(resultObj));
                }
            }
        };
    }

    /**
     * @inheritDoc
     */
    createChildren() {
        return [
            {
                detailPanel: new DetailPanel({
                    titleContent: new DetailPanelTitle(),
                    bodyContent: new DetailPanelData()
                })
            }
        ];
    }

    /**
     * @inheritDoc
     */
    view() {
        return this.renderChildren();
    }
}
