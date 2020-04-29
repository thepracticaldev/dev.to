import { h } from 'preact';
import { articlePropTypes } from '../../src/components/common-prop-types';

export const ContentTitle = ({ article }) => (
  <h2 className="crayons-story__title">
    <a href={article.path} id={`article-link-${article.id}`}>
      {article.flare_tag && (
        <span
          className="crayons-indicator"
          style={{
            background: article.flare_tag.bg_color_hex,
            color: article.flare_tag.text_color_hex,
          }}
        >
          {`#${article.flare_tag.name}`}
        </span>
      )}
      {article.class_name === 'PodcastEpisode' && (
        <span className="crayons-indicator">podcast</span>
      )}
      {article.class_name === 'User' && (
        <span
          className="crayons-indicator"
          style={{ background: '#5874d9', color: 'white' }}
        >
          person
        </span>
      )}
      {filterXSS(article.title)}
    </a>
  </h2>
);

ContentTitle.propTypes = {
  article: articlePropTypes.isRequired,
};

ContentTitle.displayName = 'ContentTitle';
