describe('Hiding article comments flow', () => {
  let articlePath;

  beforeEach(() => {
    cy.testSetup();
    cy.fixture('users/articleEditorV1User.json').as('user1');
    cy.fixture('users/articleEditorV2User.json').as('user2');

    cy.get('@user1').then((user1) => {
      cy.loginUser(user1).then(() => {
        cy.createArticle({
          title: 'My article',
          tags: ['beginner', 'ruby', 'go'],
          content: `This is a test article's contents.`,
          published: true,
        }).then((response) => {
          articlePath = response.body.current_state_path;
          cy.signOutUser(); // log out user 1 after creating the article.
          cy.clearCookies();
        });
      });
    });
  });

  it('Article author should be able to see a collapsed version of a comment after hiding and can unhide it', () => {
    const commentText = "this is a comment that's supposed to be hidden";
    cy.get('@user2').then((user) => {
      // log in user 2 to add a comment on article by user 1
      cy.loginAndVisit(user, articlePath).then(() => {
        cy.findByRole('textbox', { name: /^Add a comment to the discussion$/i })
          .focus()
          .type(commentText);
        cy.findByRole('button', { name: /^Submit$/i }).click();

        cy.signOutUser();
        cy.clearCookies();
      });
    });

    cy.get('@user1').then((user) => {
      // log in user 1 to hide the comment added by user 2
      cy.loginAndVisit(user, articlePath).then(() => {
        cy.intercept(articlePath).as('articlePage');
        cy.findByRole('button', { name: /^Toggle dropdown menu$/i }).click();
        cy.findByRole('link', { name: /^Hide (.)* comment$/i }).click();
        cy.wait('@articlePage');
        cy.signOutUser();
        cy.clearCookies();
      });
    });

    cy.get('@user2').then((user) => {
      // log in user 2 to find the comment hidden (not existing) under the article
      cy.loginAndVisit(user, articlePath).then(() => {
        cy.get('#comments').findByText(commentText).should('not.exist');
        cy.get('#comments > div > p')
          .contains("Some comments have been hidden by the post's author")
          .should('be.visible');
        cy.signOutUser();
        cy.clearCookies();
      });
    });

    cy.get('@user1').then((user) => {
      // log in user 1 to find the comment collapsed
      cy.loginAndVisit(user, articlePath).then(() => {
        cy.get('#comments').findByText(commentText).should('not.be.visible');
        // user 1 clicks on collapsed comment to expand the hidden comment
        cy.get('details').click();
        cy.get('#comments').findByText(commentText).should('be.visible');
        cy.get('#comments > div > p')
          .contains("Some comments have been hidden by the post's author")
          .should('be.visible');

        // user 1 unhides the comment
        cy.intercept(articlePath).as('articlePage');
        cy.findByRole('button', { name: /^Toggle dropdown menu$/i }).click();
        cy.findByRole('link', { name: /^Unhide (.)* comment$/i }).click();
        cy.wait('@articlePage');

        // user 1 can see the comment without any collapse
        cy.get('#comments').findByText(commentText).should('be.visible');
        cy.get('#comments')
          .findByText("Some comments have been hidden by the post's author")
          .should('not.exist');
      });
    });
  });
});
