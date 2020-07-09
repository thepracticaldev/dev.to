/* eslint-disable jest/expect-expect */
import { h } from 'preact';
import { render, fireEvent } from '@testing-library/preact';
import { ModerationArticles } from '../moderationArticles';

const getTestArticles = () => {
  const articles = [
    {
      id: 1,
      title: 'An article title',
      path: 'an-article-title-di3',
      published_at: '2019-06-22T16:11:10.590Z',
      cached_tag_list: 'discuss, javascript, beginners',
      user: {
        articles_count: 1,
        name: 'hello',
        id: 1,
      },
    },
    {
      id: 2,
      title:
        'An article title that is quite very actually rather extremely long with all things considered',
      path:
        'an-article-title-that-is-quite-very-actually-rather-extremely-long-with-all-things-considered-fi8',
      published_at: '2019-06-24T09:32:10.590Z',
      cached_tag_list: '',
      user: {
        articles_count: 3,
        name: 'howdy',
        id: 2,
      },
    },
  ];
  return JSON.stringify(articles);
};

describe('<ModerationArticles />', () => {
  beforeEach(() => {
    render(
      <div
        class="mod-index-list"
        id="mod-index-list"
        data-articles={getTestArticles()}
      >
        <div class="flag-user-modal-container hidden" />
      </div>,
    );
    render(<ModerationArticles />, document.getElementById('mod-index-list'));
  });

  it('renders a list of 2 articles', () => {
    const listOfArticles = document.querySelectorAll(
      'button.moderation-single-article',
    );
    expect(listOfArticles.length).toEqual(2);
  });

  it('renders the iframes on click', () => {
    const singleArticle = document.querySelector(
      'button.moderation-single-article',
    );
    singleArticle.click();
    const iframes = singleArticle.querySelectorAll('iframe');
    expect(iframes.length).toEqual(2);
  });

  it('toggles the "opened" class when opening or closing an article', () => {
    const singleArticle = document.querySelector(
      'button.moderation-single-article',
    );

    fireEvent.click(singleArticle);
    expect(
      singleArticle.querySelector('.article-iframes-container').classList,
    ).toContain('opened');

    fireEvent.click(singleArticle);
    expect(
      singleArticle.querySelector('.article-iframes-container').classList,
    ).not.toContain('opened');
  });

  it('adds the FlagUser Modal HTML associated with author when article opened', () => {
    // check that there is no element with class 'flag user modal'
    // click open an article
    // check that there is an element with class 'flag user modal'
    // check that the data-reactable-id attribute equates to the user id
  });
});
