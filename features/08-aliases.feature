Feature: Aliases
  https://github.com/bin-cli/bin#aliases

  Scenario: An alias can be defined in .binconfig
    Given a script '/project/bin/deploy' that outputs 'Copying to production...'
    And a file '/project/.binconfig' with content:
      """
      [deploy]
      alias=publish
      """
    When I run 'bin publish'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Multiple aliases can be defined on one line
    Given a script '/project/bin/deploy' that outputs 'Copying to production...'
    And a file '/project/.binconfig' with content:
      """
      [deploy]
      alias=publish, push
      """
    When I run 'bin push'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Multiple aliases can be defined on one line with the option 'aliases'
    Given a script '/project/bin/deploy' that outputs 'Copying to production...'
    And a file '/project/.binconfig' with content:
      """
      [deploy]
      aliases=publish, push
      """
    When I run 'bin push'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Multiple aliases can be defined on separate lines
    Given a script '/project/bin/deploy' that outputs 'Copying to production...'
    And a file '/project/.binconfig' with content:
      """
      [deploy]
      alias=publish
      alias=push
      """
    When I run 'bin push'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Aliases can be defined for directories
    Given a script '/project/bin/deploy/live' that outputs 'Copying to production...'
    And a file '/project/.binconfig' with content:
      """
      [deploy]
      alias=push
      """
    When I run 'bin push live'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Aliases can be defined for subcommands
    Given a script '/project/bin/deploy/live' that outputs 'Copying to production...'
    And a file '/project/.binconfig' with content:
      """
      [deploy live]
      alias=publish
      """
    When I run 'bin publish'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Aliases are displayed in the command list
    Given a script '/project/bin/artisan'
    And a script '/project/bin/deploy'
    And a file '/project/.binconfig' with content:
      """
      [artisan]
      alias=art

      [deploy]
      alias=publish, push
      """
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available commands
      bin artisan    (alias: art)
      bin deploy     (aliases: publish, push)
      """

  Scenario: Aliases are displayed after the help text
    Given a script '/project/bin/artisan'
    And a script '/project/bin/deploy'
    And a file '/project/.binconfig' with content:
      """
      [artisan]
      alias=art
      help=Run Laravel Artisan command with the appropriate version of PHP

      [deploy]
      alias=publish, push
      help=Sync the code to the live server
      """
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available commands
      bin artisan    Run Laravel Artisan command with the appropriate version of PHP (alias: art)
      bin deploy     Sync the code to the live server (aliases: publish, push)
      """

  Scenario: Aliases are subject to unique prefix matching
    Given a script '/project/bin/deploy' that outputs 'Copying to production...'
    And a file '/project/.binconfig' with content:
      """
      [deploy]
      alias=publish
      """
    When I run 'bin pub'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Multiple aliases for the same command are treated as one match
    Given a script '/project/bin/deploy' that outputs 'Copying to production...'
    And a file '/project/.binconfig' with content:
      """
      [deploy]
      alias=publish, push
      """
    When I run 'bin pu'
    Then it is successful
    And the output is 'Copying to production...'

  Scenario: Defining an alias that conflicts with a command causes an error
    Given a script '/project/bin/one'
    And a script '/project/bin/two'
    And a file '/project/.binconfig' with content:
      """
      [one]
      alias=two
      """
    When I run 'bin'
    Then it fails with exit code 246
    And the error is "bin: The alias 'two' conflicts with an existing command in /project/.binconfig line 2"

  Scenario: Defining an alias that conflicts with another alias causes an error
    Given a script '/project/bin/one'
    And a script '/project/bin/two'
    And a file '/project/.binconfig' with content:
      """
      [one]
      alias=three

      [two]
      alias=three
      """
    When I run 'bin'
    Then it fails with exit code 246
    And the error is "bin: The alias 'three' conflicts with an existing alias in /project/.binconfig line 5 (originally defined in /project/.binconfig line 2)"
