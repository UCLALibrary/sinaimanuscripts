/// <reference types="Cypress" />
describe('Sinai Search', () => {
  beforeEach(() => {
    cy.visit(Cypress.env('SINAI_BASE_URL') + '/catalog');
    cy.get('.si-terms-of-use-modal-block');
    cy.contains('p', 'Manuscript images');
    cy.get('.si-terms-of-use-modal-button').click();
  });

  it('Search Blank', () => {
    cy.get('[id=search]').click();
    cy.contains('span', 'You searched for:').should('not.exist');
  });

  it('Search Not Found', () => {
    cy.get('input.search-q').type('unicorn');
    cy.get('[id=search]').click();
    cy.contains('h2', '0 Catalog Results').should('exist');
  });

  it('Search Found', () => {
    cy.clearCookie('sinai_authenticated_1year');
    cy.setCookie('sinai_authenticated_1year', 'true')
    cy.get('input.search-q').type('manuscript');
    cy.get('[id=search]').click();
    cy.get('.search-count__heading').contains('Catalog Results');
    cy.get('.document-position-1 .document__gallery-thumbnail--sinai a').first().click();
    cy.contains('h2', 'Item Overview');
  });

  it('Search Shelfmark Found', () => {
    cy.get('input.search-q').type('sinai syriac 100');
    cy.get('select').select('Shelfmark').should('have.value', 'shelfmark_tsi');
    cy.get('[id=search]').click();
    cy.get('.search-count__heading').contains('Catalog Results');
  });

  it('Search Title Found', () => {
    cy.get('input.search-q').type('sinai');
    cy.get('select').select('Title').should('have.value', 'title_tesim descriptive_title_tesim contents_tesim contents_note_tesim alternative_title_tesim uniform_title_tesim');
    cy.get('[id=search]').click();
    cy.get('.search-count__heading').contains('Catalog Results');
  });

  it('Search Sort', () => {
    cy.get('[id=search]').click();
    cy.get('.search-widget__dropdown').contains('Sort by Shelfmark (A-Z)');
    cy.get('input.search-q').type('sinai');
    cy.get('.search-widget__dropdown').contains('Relevance');
  });
  // <a data-turbolinks="false" href="#facet-script_sim">Script</a>
  it('Search Facet are visbile', () => {
    cy.get('[id=search]').click();
    cy.get('[data-target="#facet-script_sim"]').click();
    cy.contains('a', 'Estrangela').click({ force: true });;
    cy.get('[title="Estrangela"]', { timeout: 100000 });
  });
});
