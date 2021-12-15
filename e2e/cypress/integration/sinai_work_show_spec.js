describe('Sinai Work show pages', () => {
  it('Sinai Syriac 2A', () => {
    cy.visit(Cypress.env('SINAI_BASE_URL') + '/catalog/' + encodeURIComponent('ark:/21198/z1x07bdf'));
    cy.contains('div.title-row-show--siani', 'Sinai Syriac 2A');
    cy.percySnapshot();
  });

  it('Sinai Syriac 45', () => {
    cy.visit(Cypress.env('SINAI_BASE_URL') + '/catalog/' + encodeURIComponent('ark:/21198/z1zs40v7'));
    cy.contains('div.title-row-show--siani', 'Sinai Syriac 45');
    //cy.get('.item-page__title')
    cy.percySnapshot();
  });

  it('Sinai Syriac 70', () => {
    cy.visit(Cypress.env('SINAI_BASE_URL') + '/catalog/' + encodeURIComponent('ark:/21198/z1s76kq5'));
    cy.contains('div.title-row-show--siani', 'Sinai Syriac 70');
    cy.percySnapshot();
  });

  it('IIIF Manifest Tooltip', () => {
    cy.visit(Cypress.env('SINAI_BASE_URL') + '/catalog/' + encodeURIComponent('ark:/21198/z1s76kq5'));
    cy.get('.si-link-iiif-manifest').trigger('mouseover');
    cy.contains('div.tooltip-inner','IIIF Manifest');
    cy.percySnapshot();
  });

  it('Sinai Not Logged In', () => {
    cy.clearCookie('sinai_authenticated');
    cy.setCookie('sinai_authenticated', 'false')
    cy.visit(Cypress.env('SINAI_BASE_URL') + '/catalog/' + encodeURIComponent('ark:/21198/z1s76kq5'));
    cy.percySnapshot();
  });
});
