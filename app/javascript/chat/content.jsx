import { h, Component } from 'preact';
import PropTypes from 'prop-types';
import Article from './article';
import ChannelRequest from './channelRequest';
import RequestManager from './requestManager';
import ChatChannelSettings from './ChatChannelSettings/ChatChannelSettings';

function display(resource) {
  if (resource.type_of === 'loading-user') {
    return <div className="loading-user" title="Loading user" />;
  }

  if (resource.type_of === 'article') {
    return <Article resource={resource} />;
  }

  if (resource.type_of === 'channel-request') {
    return (
      <ChannelRequest
        resource={resource.data}
        handleJoiningRequest={resource.handleJoiningRequest}
      />
    );
  }

  if (resource.type_of === 'channel-request-manager') {
    return (
      <RequestManager
        resource={resource.data}
        handleRequestRejection={resource.handleRequestRejection}
        handleRequestApproval={resource.handleRequestApproval}
      />
    );
  }

  return null;
}

function smartSvgIcon(content, d) {
  return (
    <svg
      data-content={content}
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      width="24"
      height="24"
    >
      <path data-content={content} fill="none" d="M0 0h24v24H0z" />
      <path data-content={content} d={d} />
    </svg>
  );
}

export default class Content extends Component {
  static defaultProps = {
    resource: undefined,
  };

  render() {
    const { resource, onTriggerContent, fullscreen } = this.props;

    if (!resource) {
      return '';
    }

    return (
      <div
        role="presentation"
        className="activechatchannel__activecontent activechatchannel__activecontent--sidecar"
        id="chat_activecontent"
        onClick={onTriggerContent}
      >
        <button
          type="button"
          className="activechatchannel__activecontentexitbutton crayons-btn crayons-btn--secondary"
          data-content="exit"
          title="exit"
        >
          {smartSvgIcon(
            'exit',
            'M12 10.586l4.95-4.95 1.414 1.414-4.95 4.95 4.95 4.95-1.414 1.414-4.95-4.95-4.95 4.95-1.414-1.414 4.95-4.95-4.95-4.95L7.05 5.636z',
          )}
        </button>
        <button
          type="button"
          className="activechatchannel__activecontentexitbutton activechatchannel__activecontentexitbutton--fullscreen crayons-btn crayons-btn--secondary"
          data-content="fullscreen"
          style={{ left: '39px' }}
          title="fullscreen"
        >
          {' '}
          {fullscreen
            ? smartSvgIcon(
                'fullscreen',
                'M18 7h4v2h-6V3h2v4zM8 9H2V7h4V3h2v6zm10 8v4h-2v-6h6v2h-4zM8 15v6H6v-4H2v-2h6z',
              )
            : smartSvgIcon(
                'fullscreen',
                'M20 3h2v6h-2V5h-4V3h4zM4 3h4v2H4v4H2V3h2zm16 16v-4h2v6h-6v-2h4zM4 19h4v2H2v-6h2v4z',
              )}
        </button>
        {display(resource)}
      </div>
    );
  }
}

Content.displayName = 'Content';

Content.propTypes = {
  resource: PropTypes.shape({
    type_of: PropTypes.string,
    data: PropTypes.object,
    handleJoiningRequest: PropTypes.func,
  }),
  onTriggerContent: PropTypes.func.isRequired,
  fullscreen: PropTypes.bool.isRequired,
};
