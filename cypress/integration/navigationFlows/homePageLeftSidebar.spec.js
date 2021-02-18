describe('Home Page Left Sidebar', () => {
  beforeEach(() => {
    cy.testSetup();
  });

  it('should open the "More" links', () => {
    // Go to home page
    cy.visit('/');

    // Click on the More... button in the nav
    cy.get('#page-content-inner').within(() => {
      cy.findByText('More...').click();
      cy.findByText('More...').should('have.class', 'hidden');
      cy.findByText('Nav link 5').should('not.have.class', 'hidden');
      // visit another page with InstantClick
      cy.findByText('Nav link 0').click();
    });

    // go back to the homepage with InstantClick
    cy.intercept('/?i=i').as('homepage');
    cy.get('.site-logo').click();
    cy.wait('@homepage');

    // repeat and assert
    cy.get('#page-content-inner').within(() => {
      cy.findByText('More...').click();
      cy.findByText('More...').should('have.class', 'hidden');
      cy.findByText('Nav link 5').should('not.have.class', 'hidden');
    });
  });
});
