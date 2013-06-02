Feature: cookbook command
  As a Cookbook author
  I want a way to quickly generate a Cookbook skeleton that contains supporting Berkshelf files
  So I can quickly and automatically generate a Cookbook containing Berkshelf supporting files or other common supporting files

  Scenario: creating a new cookbook skeleton
    When I run the cookbook command to create "sparkle_motion"
    Then I should have a new cookbook skeleton "sparkle_motion"
    And the exit status should be 0

  Scenario Outline: creating a new cookbook skeleton with affirmative options
    When I run the cookbook command to create "sparkle_motion" with options:
      | --<option> |
    Then I should have a new cookbook skeleton "sparkle_motion" with <feature> support
    And the exit status should be 0

  Examples:
    | option        | feature       |
    | foodcritic    | Foodcritic    |
    | chef-minitest | Chef-Minitest |
    | scmversion    | SCMVersion    |
    | no-bundler    | no Bundler    |
    | skip-git      | no Git        |
    | skip-vagrant  | no Vagrant    |

  Scenario Outline: creating a new cookbook skeleton with options without the supporting gem installed
    Given the gem "<gem>" is not installed
    When I run the cookbook command to create "sparkle_motion" with options:
      | --<option> |
    Then I should have a new cookbook skeleton "sparkle_motion" with <feature> support
    And the output should contain a warning to suggest supporting the option "<option>" by installing "<gem>"
    And the exit status should be 0

  Examples:
    | option     | feature    | gem             |
    | foodcritic | Foodcritic | foodcritic      |
    | scmversion | SCMVersion | thor-scmversion |

  Scenario: creating a new cookbook skeleton with bundler support without bundler installed
    Given the gem "bundler" is not installed
    When I run the cookbook command to create "sparkle_motion"
    Then I should have a new cookbook skeleton "sparkle_motion"
    And the output should contain a warning to suggest supporting the default for "bundler" by installing "bundler"
    And the exit status should be 0
