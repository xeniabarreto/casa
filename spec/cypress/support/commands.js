// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add("login", (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add("drag", { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add("dismiss", { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This is will overwrite an existing command --
// Cypress.Commands.overwrite("visit", (originalFn, url, options) => { ... })
Cypress.Commands.add('volunteerSignin', () => {
  // the volunteer info should be available via the seeds
    cy.request('POST', '/users/sign_in', {
      user: {
        email: 'volunteer1@example.com',
        password: '123456'
      }
    })
    // cy.visit('/')
    // cy.get('#user_email').type('volunteer1@example.com')
    // cy.get('#user_password').type('123456')
    // cy.get('.actions > .btn').click()
})
