import { helpers } from "LegacyAdapter";
import { atomic, composite, UIComponent } from "MPageFusion";
import { EVENTS } from "../constants/MPagesFusionCustomComponentConstants";
import MPagesFusionCustomComponentDetailPanel
    from "./MPagesFusionCustomComponentDetailPanel";

const {
    table: {
        Table
    }
} = atomic;
const {
    detailPanel: {
        DetailPanel
    }
} = composite;
const {
    detailPanel
} = helpers;

/**
* Returns an array of rows to be used by the Table control.
* @param {Array} results Array of data representing a single result
* @param {Number} subsectionId The current index value of the group
*
* @returns {Object} An object containing unique keys per row and render-able data
*/
const createResultRows = (results, subsectionId) => {
    return results.map((result, index) => {
        return {
            meta: result,
            // Ideally, a key should be unique identifier like a clinical_even_id or something similar.
            // For this example we are going to create a string of the following format `GROUP1|ROW2` where GROUP1 indicates first subsection and ROW2 indicates second row in the Table.
            // You might need to change this to something specific to your component's data model.
            key: `${subsectionId}|${index}|${result.ACTIVITY_ID}`,
            data: [
                {
                    display: result.ACTIVITY_NAME
                },
                {
                    display: result.DURATION
                },
                {
                    display: result.DAYS_PER_WEEK
                }
            ]
        };
    });
};
/**
 * Returns an array of subSections to be  used by the Table UI Component
 * @param {Array} dataObj Raw data object.
 * @returns {Object} An object containing unique keys per row and renderable data
 */
const createSubsections = (dataObj) => {
    // Ideally, a key should be unique identifier like a clinical_even_id or something similar.
    // For this example we are going to create a string of the following format `GROUP1` where GROUP2 indicates second subsection
    return dataObj.ACTIVITY_LEVELS.map((activityLevel, index) => {
        return {
            key: activityLevel.LEVEL_ID,
            expand: true,
            display: activityLevel.LEVEL_NAME,
            rows: createResultRows(dataObj.ACTIVITY.filter(activity =>
                (activity.ACTIVITY_LEVEL === activityLevel.LEVEL_NAME)), activityLevel.LEVEL_ID)
        };
    });
};

/**
 * This function is used to deselect the table row when the detail panel is closed at the application level.
 * @param {string} rowKey A codified string in the following format `GROUP1|ROW1`
 * @param {Table} table The Table UI Component
 * @returns {undefined} This function does not return a value
 */
const deselectRow = (rowKey, table) => {
    const subsections = table.getProp("subSections");
    const keyArray = rowKey.split("|");
    const rowIndex = parseInt(keyArray[1], 10);
    table.setProp("subSections", subsections.map((subsection) => {
        if (subsection.key === parseInt(keyArray[0], 10)) {
            subsection.rows[rowIndex].isSelected = false;
        }
        return subsection;
    }));
};

/**
 * The MPagesFusionCustomComponentBody class.
 * @class MPagesFusionCustomComponentBody
 */
export default class MPagesFusionCustomComponentBody extends UIComponent {
    constructor() {
        super();
        this.lastSelectedRowKey = "";
    }

    /**
     * @inheritDoc
     */
    initialProps() {
        return {
            data: null
        };
    }

    /**
     * @inheritDoc
     */
    propChangeHandlers() {
        return {
            data: (data) => {
                this.getChild("table").setProp("subSections", createSubsections(data));
            }
        };
    }

    /**
     * @inheritDoc
     */
    createChildren() {
        return [
            {
                table: new Table({
                    columns: [
                        {
                            display: "Activity Name",
                            key: "column1"
                        },
                        {
                            display: "Time spent per Week",
                            key: "column3"
                        },
                        {
                            display: "Days per Week",
                            key: "column4"
                        }
                    ],
                    rowProps: {
                        dualColumn: false,
                        selectable: true,
                        hoverable: true
                    }
                })
            },
            {
                panel: new MPagesFusionCustomComponentDetailPanel()
            }];
    }

    /**
     * @inheritDoc
     */
    afterCreate() {
        this.on(Table.EVENTS.ROW_SELECTION_CHANGE, (selectedRowsObj) => {
            // Prevent the event from bubbling any further since we will handle it here.
            this.stopPropagation(Table.EVENTS.ROW_SELECTION_CHANGE);
            // Handle logic for updating content in DetailPanel based on selection
            const row = selectedRowsObj.selected.length && selectedRowsObj.selected[0];
            if (row && row.isSelected) {
                // The meta field holds the original data element so that we can easily access it
                const panel = this.getChild("panel");
                panel.setProp("result", row.meta);
                // Use the detailPanel helpers to open the detail panel and handle scenarios where it is denied
                detailPanel.loadPanel(this, { panel })
                    .then(() => {
                        // Save off the key for the last selected row
                        this.lastSelectedRowKey = row.key;
                    })
                    .catch(() => {
                        // Detail Panel opening was rejected, so deselect the selected row
                        deselectRow(this.lastSelectedRowKey, this.getChild("table"));
                        this.lastSelectedRowKey = "";
                    });
            } else {
                detailPanel.closePanel(this);
                // Reapply the table data which will cause a reset of the selection
                this.setProp("data", this.getProp("data"));
                this.update();
            }
        });

        this.on(DetailPanel.EVENTS.REQUEST_CLOSE, () => {
            const table = this.getChild("table");
            detailPanel.closePanel(this);
            deselectRow(this.lastSelectedRowKey, table);
            this.lastSelectedRowKey = "";
            table.update();
        });

        this.on(EVENTS.DETAIL_PANEL.UNLOAD, (resolve, reject) => {
            const table = this.getChild("table");
            deselectRow(this.lastSelectedRowKey, table);
            this.lastSelectedRowKey = "";
            table.update();
            resolve();
        });
    }

    /**
     * @inheritDoc
     */
    view(el, props, children, mappedChildren) {
        return mappedChildren.table.render();
    }
}
