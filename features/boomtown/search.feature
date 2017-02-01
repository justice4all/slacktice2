Feature: search

  Scenario: keyword search
    Given I'm on the home page
     When I search for "King street"
     Then "King street" appears in the filter list
      And there are at least 20 results
      And each result is in Sullivan's Island

   Scenario: new user saves a search
     Given I'm on the home page
      When I search for "Charleston"
       And I click "Save Search"
       And I complete registration
       And I click "Save Search"
       And I save the search as "CHS"
      Then I see "CHS" in my saved searches
       And I have a user account