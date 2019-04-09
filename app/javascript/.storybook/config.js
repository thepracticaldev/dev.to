import { configure } from '@storybook/preact';
// import '../../assets/stylesheets/minimal.scss';

// automatically import all files ending in *.stories.js
const req = require.context('../', true, /.stories.jsx$/);
function loadStories() {
  req.keys().forEach(filename => req(filename));
}

configure(loadStories, module);
