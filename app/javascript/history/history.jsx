import { h, Component } from 'preact';
import { PropTypes } from 'preact-compat';
import debounce from 'lodash.debounce';
import setupAlgoliaIndex from '../src/utils/algolia';

import { ItemListLoadMoreButton } from '../src/components/ItemList/ItemListLoadMoreButton';
import { ItemListTags } from '../src/components/ItemList/ItemListTags';
import { ItemListItem } from '../src/components/ItemList/ItemListItem';

export class History extends Component {
  constructor(props) {
    super(props);

    this.handleTyping = debounce(this.handleTyping.bind(this), 300, {
      leading: true,
    });

    const { availableTags } = this.props;
    this.state = {
      query: '',
      index: null,

      page: 0,
      hitsPerPage: 100,
      totalCount: 0,

      items: [],
      itemsLoaded: false,

      availableTags,
      selectedTags: [],

      showLoadMoreButton: false,
    };
  }

  componentDidMount() {
    const index = setupAlgoliaIndex({
      containerId: 'history',
      indexName: 'UserHistory',
    });

    // get default result set from Algolia
    const { hitsPerPage } = this.state;
    index.search('', { hitsPerPage }).then(content => {
      this.setState({
        items: content.hits,
        totalCount: content.nbHits,
        index,
        itemsLoaded: true,
        showLoadMoreButton: content.hits.length === hitsPerPage,
      });
    });
  }

  handleTyping = event => {
    const query = event.target.value;
    const { selectedTags } = this.state;

    this.setState({ page: 0, items: [] });
    this.search(query, { tags: selectedTags });
  };

  toggleTag = (event, tag) => {
    event.preventDefault();

    const { query, selectedTags } = this.state;
    const newTags = selectedTags;
    if (newTags.indexOf(tag) === -1) {
      newTags.push(tag);
    } else {
      newTags.splice(newTags.indexOf(tag), 1);
    }

    this.setState({ selectedTags: newTags, page: 0, items: [] });
    this.search(query, { tags: newTags });
  };

  loadNextPage = () => {
    const { query, selectedTags, page } = this.state;
    this.setState({ page: page + 1 });
    this.search(query, { selectedTags });
  };

  search(query, { tags }) {
    const { index, hitsPerPage, page, items } = this.state;
    const filters = { hitsPerPage, page };

    if (tags && tags.length > 0) {
      filters.tagFilters = tags;
    }

    index.search(query, filters).then(content => {
      const allItems = [...items, ...content.hits];

      this.setState({
        query,
        items: allItems,
        totalCount: content.nbHits,
        showLoadMoreButton: content.hits.length === hitsPerPage,
      });
    });
  }

  renderEmptyItems() {
    const { selectedTags, query } = this.state;

    return (
      <div>
        <div className="items-empty">
          <h1>
            {selectedTags.length === 0 && query.length === 0
              ? 'Your History is Lonely'
              : 'Nothing with this filter 🤔'}
          </h1>
        </div>
      </div>
    );
  }

  render() {
    const {
      items,
      itemsLoaded,
      totalCount,
      availableTags,
      selectedTags,
      showLoadMoreButton,
    } = this.state;

    const itemsToRender = items.map(item => <ItemListItem item={item} />);

    return (
      <div className="home item-list">
        <div className="side-bar">
          <div className="widget filters">
            <input
              onKeyUp={this.handleTyping}
              placeHolder="search your history"
            />

            <ItemListTags
              availableTags={availableTags}
              selectedTags={selectedTags}
              onClick={this.toggleTag}
            />
          </div>
        </div>

        <div className="items-container">
          <div className={`results ${itemsLoaded ? 'results--loaded' : ''}`}>
            <div className="results-header">
              History
              {` (${totalCount > 0 ? totalCount : 'empty'})`}
            </div>
            {items.length > 0 ? itemsToRender : this.renderEmptyItems()}
          </div>

          <ItemListLoadMoreButton
            show={showLoadMoreButton}
            onClick={this.loadNextPage}
          />
        </div>
      </div>
    );
  }
}

History.propTypes = {
  availableTags: PropTypes.arrayOf(PropTypes.string).isRequired,
};
