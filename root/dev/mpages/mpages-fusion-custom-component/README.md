# MPagesFusionCustomComponent (mpages-fusion-custom-component)

> Standard Workflow FusionComponent for your data model.

### Main file

`MPagesFusionCustomComponent.js`

## Components from MPageFusion

## Data Retrieval

Scripts involved in Retrieval of Data

-   mp_my_component_script

## External global objects

-   FusionComponent

## Node dependencies involved

-   `mpage-gaia` for building source and executing unit test
-   `gaia-preset-public` for loading MPages Gaia plugins

## Running development task

```bash
Only once
npm install

Running Unit test
npm run test

Running lint task
npm run lint

Building source
npm run build
```

## Developing multiple components

Developing multiple components is just a matter of creating new component classes in the `src/` folder, and exporting them through the `index.js` file. Ensure your entry point is properly configured within Gaia.
Ideally, each custom component should reside in its own folder. Because Gaia uses webpack to create the final artifacts, any libraries placed in the `package.json` will be added to the final `custom-components.js` if they are imported in a component.
