Feature: Automatic exclusions
  https://github.com/bin-cli/bin#automatic-exclusions

  Scenario: Scripts starting with '_' are excluded from listings
    Given a script '/project/bin/visible'
    And a script '/project/bin/_hidden'
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available commands
      bin visible
      """

  Scenario: Scripts starting with '_' can be executed
    Given a script '/project/bin/_hidden' that outputs 'Hidden script'
    When I run 'bin _hidden'
    Then it is successful
    And the output is 'Hidden script'

  Scenario: Scripts starting with '.' are excluded from listings
    Given a script '/project/bin/visible'
    And a script '/project/bin/.hidden'
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available commands
      bin visible
      """

  Scenario: Scripts starting with '.' cannot be executed
    Given a script '/project/bin/.hidden'
    When I run 'bin .hidden'
    Then the exit code is 127
    And there is no output
    And the error is "Executable names may not start with '.'"

  Scenario: Files that are not executable are listed as warnings
    Given a script '/project/bin/executable'
    And an empty file '/project/bin/not-executable'
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available commands
      bin executable

      Warning: The following files are not executable (chmod +x):
      /project/bin/not-executable
      """

  Scenario: Files that are not executable cannot be executed
    Given an empty file '/project/bin/not-executable'
    When I run 'bin not-executable'
    Then the exit code is 126
    And there is no output
    And the error is "'/project/bin/not-executable' is not executable (chmod +x)"

  Scenario: Non-executable files are not listed in the project root
    Given a file '/project/.binconfig' with content 'root=.'
    And a script '/project/executable'
    And an empty file '/project/not-executable'
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available commands
      bin executable
      """

  Scenario: Common non-executable file types are not listed in the project root even if they are executable
    Given a file '/project/.binconfig' with content 'root=.'
    And a script '/project/executable1.sh'
    And a script '/project/executable2.json'
    And a script '/project/executable3.md'
    And a script '/project/executable4.txt'
    And a script '/project/executable5.yaml'
    And a script '/project/executable6.yml'
    When I run 'bin'
    Then it is successful
    And the output is:
      """
      Available commands
      bin executable1
      """

  Scenario: Common non-executable file types can still be run manually
    Given a file '/project/.binconfig' with content 'root=.'
    And a script '/project/executable.json' that outputs 'Executable'
    When I run 'bin executable'
    Then it is successful
    And the output is 'Executable'

  Scenario Template: Common bin directories are ignored when searching parent directories
    Given a script '<bin>/hello'
    And the working directory is '<workdir>'
    When I run 'bin hello'
    Then the exit code is 127
    And there is no output
    And the error is "Could not found 'bin' directory or '.binconfig' file from <workdir>"

    Examples:
      | bin            | workdir                |
      | /bin           | /example               |
      | /usr/bin       | /usr/example           |
      | /snap/bin      | /snap/example          |
      | /usr/local/bin | /usr/local/bin/example |
      | /home/user/bin | /home/user/example     |

  Scenario Template: Common bin directories are not ignored if there is a .binconfig directory in the parent directory
    Given a script '<bin>/hello'
    And an empty file '<config>'
    And the working directory is '<workdir>'
    When I run 'bin hello'
    Then the exit code is 127
    And there is no output
    And the error is "Could not found 'bin' directory or '.binconfig' file from <workdir>"

    Examples:
      | bin            | config                | workdir                |
      | /bin           | /.binconfig           | /example               |
      | /usr/bin       | /usr/.binconfig       | /usr/example           |
      | /snap/bin      | /snap/.binconfig      | /snap/example          |
      | /usr/local/bin | /usr/local/.binconfig | /usr/local/bin/example |
      | /home/user/bin | /home/user/.binconfig | /home/user/example     |

  Scenario Template: Common bin directories are not ignored if there is a .binconfig directory in the bin directory
    Given a script '<bin>/hello'
    And an empty file '<config>'
    And the working directory is '<workdir>'
    When I run 'bin hello'
    Then the exit code is 127
    And there is no output
    And the error is "Could not found 'bin' directory or '.binconfig' file from <workdir>"

    Examples:
      | bin            | config                    | workdir                |
      | /bin           | /bin/.binconfig           | /example               |
      | /usr/bin       | /usr/bin/.binconfig       | /usr/example           |
      | /snap/bin      | /snap/bin/.binconfig      | /snap/example          |
      | /usr/local/bin | /usr/local/bin/.binconfig | /usr/local/bin/example |
      | /home/user/bin | /home/user/bin/.binconfig | /home/user/example     |
