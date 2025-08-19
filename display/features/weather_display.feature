Feature: Weather display
  As a visitor
  I want to open the weather display page
  So that I can see key UI elements

  Scenario: Opening the main page shows the title
    When I open the main page
    Then I should see the title

  Scenario: Main page shows default cities
    When I open the main page
    Then I should see the default cities

  Scenario: Main page shows table headers
    When I open the main page
    Then I should see the table headers

  Scenario: Main page shows time and temperatures
    When I open the main page
    Then I should see time entries
    And I should see temperatures




