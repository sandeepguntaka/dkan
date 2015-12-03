@api @javascript
Feature: Portal Administrators administer groups
  In order to manage site organization
  As a Portal Administrator
  I want to administer groups

  Portal administrators needs to be able to create, edit, and delete
  groups. They need to be able to set group membership by adding and removing
  users and setting group roles and permissions.


  Background:
    Given pages:
      | title     | url             |
      | Groups    | /groups         |
      | Content   | /admin/content/ |
    Given users:
      | name    | mail             | roles                |
      | John    | john@example.com    | administrator        |
      | Badmin  | admin@example.com   | administrator        |
      | Gabriel | gabriel@example.com | editor     |
      | Jaz     | jaz@example.com     | editor     |
      | Katie   | katie@example.com   | editor     |
      | Martin  | martin@example.com  | editor     |
      | Celeste | celeste@example.com | editor     |
    Given groups:
      | title    | author | published |
      | Group 01 | John   | Yes       |
      | Group 02 | John   | Yes       |
      | Group 03 | John   | No        |
    And group memberships:
      | user    | group    | role on group        | membership status |
      | Gabriel | Group 01 | administrator member | Active            |
      | Katie   | Group 01 | member               | Active            |
      | Jaz     | Group 01 | member               | Pending           |
      | Celeste | Group 02 | member               | Active            |
    And datasets:
      | title      | publisher | tags       | author  | published | description                |
      | Dataset 01 | Group 01  | price      | Katie   | Yes       | Increase of toy prices     |
      | Dataset 02 | Group 01  | price      | Katie   | No        | Cost of oil in January     |
      | Dataset 03 | Group 01  | election   | Gabriel | Yes       | Election districts         |
    And resources:
      | title       | publisher | format | author | published | dataset    | description |
      | Resource 01 | Group 01  | csv    | Katie  | Yes       | Dataset 01 |             |
      | Resource 02 | Group 01  | html   | Katie  | Yes       | Dataset 01 |             |

  Scenario: Create group
    Given I am logged in as "John"
    And I am on "Groups" page
    And I follow "Add Group"
    When I fill in the following:
      | Title  |  My group      |
      | Body   | This is a body |
    And I press "Save"
    Then I should see the success message "Group My group has been created"
    And I should see the heading "My group"
    And I should see "This is a body"

  @fixme @testBug
    #TODO: Break up undefined step into behat steps (I fill in the following...I press submit)
    #When I fill in the "member" form for "Katie" - undefined
  Scenario: Add a group member on any group
    Given I am logged in as "John"
    And I am on "Group 02" page
    And I click "Group"
    And I click "Add people"
    When I fill in the "member" form for "Katie"
    And I press "Add users"
    Then I should see "Katie has been added to the group Group 02"
    When I am on "Group 02" page
    And I click "Members" in the "primary tabs" region
    Then I should see "Katie" in the "group members" region

  Scenario: Remove a group member from any group
    Given I am logged in as "John"
    And I am on "Group 01" page
    And I click "Group"
    And I click "People"
    When I click "remove" in the "Katie" row
    And I press "Remove"
    Then I should see "The membership was removed"
    And I am on "Group 01" page
    And I click "Members" in the "primary tabs" region
    And I should see "Katie" in the "group members" region

  Scenario: Delete any group
    Given I am logged in as "John"
    And I am on "Group 02" page
    When I click "Edit"
    Then I should see the button "Delete"
    When I press "Delete"
    Then I should see "Are you sure you want to delete"
    When I press "Delete"
    Then I should see "Group Group 02 has been deleted"

  Scenario: Edit any group
    Given I am logged in as "John"
    And I am on "Group 02" page
    When I click "Edit"
    And I fill in "Body" with "Group 02 edited"
    And I press "Save"
    Then I should see "Group Group 02 has been updated"
    And I should be on the "Group 02" page

  Scenario: Edit membership status of group member on any group
    Given I am logged in as "John"
    And I am on "Group 01" page
    And I click "Group"
    And I click "People"
    And I click "edit" in the "Katie" row
    When I select "Blocked" from "Status"
    And I press "Update membership"
    Then I should see "The membership has been updated"

  Scenario: Edit group roles of group member on any group
    Given I am logged in as "John"
    And I am on "Group 01" page
    And I click "Group"
    And I click "People"
    And I click "edit" in the "Katie" row
    When I check "administrator member"
    And I press "Update membership"
    Then I should see "The membership has been updated"

  Scenario: View permissions of any group
    Given I am logged in as "John"
    And I am on "Group 01" page
    And I click "Group"
    When I click "Permissions (read-only)"
    Then I should see the list of permissions for the group

  Scenario: View group roles of any group
    Given I am logged in as "John"
    And I am on "Group 01" page
    And I click "Group"
    When I click "Roles (read-only)"
    Then I should see the list of roles for the group "Group 01"

  @fixme @testBug
    #TODO: Need to define for getting list of permissions
    # Then I should see the list of permissions for "<role name>" role - undefined
  Scenario Outline: View group role permissions of any group
    Given I am logged in as "John"
    And I am on "Group 01" page
    And I click "Group"
    And I click "Roles (read-only)"
    When I click "view permissions" in the "<role name>" row
    Then I should see the list of permissions for "<role name>" role

    Examples:
      | role name            |
      | non-member           |
      | member               |
      | administrator member |

  Scenario: View the number of members on any group
    Given I am logged in as "John"
    And I am on "Group 01" page
    And I click "Group"
    When I click "People"
    Then I should see "Total members: 4"

  Scenario: View the number of content on any group
    Given I am logged in as "John"
    And I am on "Group 01" page
    And I click "Group"
    When I click "People"
    Then I should see "Total content: 4"

  @fixme @dkanBug
    # TODO: Sub-groups not in dkan, this should be deleted
    # Parent group not on edit page, does not look like sub-groups are enabled on dkan currently
  Scenario: Add a sub-group on any group
    Given I am logged in as "John"
    And I am on "Group 01" page
    When I click "Edit"
    Then I should see "Parent group"
    When I fill in "Parent group" with "Group 02"
    And I press "Update"
    Then I should see "Group Group 01 has been updated"
    When I am on "Group 02" page
    Then I should see "Group 01" in the "sub-groups" region

  # TODO: Change to use Workbench instead of /content


  Scenario: View list of unpublished groups
    Given I am logged in as "John"
    And I am on "Content" page
    When I select "not published" from "status"
    And I select "group" from "type"
    And I press "Filter"
    Then I should see "Group 03"
    And I should see "1" items in the "search content results" region

  Scenario: View the details of an unpublished group
    Given I am logged in as "John"
    When I am on "Group 03" page
    #TODO: What should actually be tested as far as details?
    Then I should be on the "Group 03" page


