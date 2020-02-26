Feature: Config
  Background:
    Given a file named "test.md" with:
    """
    This is a very important sentence. There is a sentence here too. javascript agendize

    """
    And a file named "test.py" with:
    """
    # There is always something to say. Very good! (e.g., this is good)
    # The centre issue is that everything is going to the center.

    """

  Scenario: MinAlertLevel = warning
    Given a file named ".vale" with:
    """
    StylesPath = ../../styles/
    MinAlertLevel = warning

    [*]
    BasedOnStyles = vale
    """
    When I run vale "test.md"
    Then the output should contain exactly:
    """
    test.md:1:11:vale.Editorializing:Consider removing 'very'
    """
    And the exit status should be 0

  Scenario: MinAlertLevel = error
    Given a file named ".vale" with:
    """
    MinAlertLevel = error

    [*]
    BasedOnStyles = vale

    vale.Spelling = NO
    """
    When I run vale "test.md"
    Then the output should contain exactly:
    """
    """
    And the exit status should be 0

  Scenario: External config (direct)
    When I lint with config "../../fixtures/styles/demo/_vale"
    Then the output should contain exactly:
      """
      test.md:15:60:demo.Spellcheck:Did you really mean 'codeblock'?
      test.md:34:29:demo.Filters:Did you really mean 'TODO'?
      test.md:36:3:demo.Filters:Did you really mean 'TODO'?
      test.md:36:16:demo.Filters:Did you really mean 'FIXME'?
      test.md:40:21:demo.Filters:Did you really mean 'FIXME'?
      test.md:42:9:demo.Spellcheck:Did you really mean 'Monokai'?
      test.md:44:5:demo.Filters:Did you really mean 'TODO'?
      test.md:46:3:demo.Filters:Did you really mean 'TODO'?
      """
    And the exit status should be 0

  Scenario: External config
    When I lint with config "../../fixtures/styles/demo"
    Then the output should contain exactly:
      """
      test.md:15:60:demo.Spellcheck:Did you really mean 'codeblock'?
      test.md:34:29:demo.Filters:Did you really mean 'TODO'?
      test.md:36:3:demo.Filters:Did you really mean 'TODO'?
      test.md:36:16:demo.Filters:Did you really mean 'FIXME'?
      test.md:40:21:demo.Filters:Did you really mean 'FIXME'?
      test.md:42:9:demo.Spellcheck:Did you really mean 'Monokai'?
      test.md:44:5:demo.Filters:Did you really mean 'TODO'?
      test.md:46:3:demo.Filters:Did you really mean 'TODO'?
      """
    And the exit status should be 0

  Scenario: Non-Existent Config
    When I inspect "/misc/one/two/three/four"
    Then the output should contain exactly:
      """
      WARNING: Missing or invalid config file.

      See https://errata-ai.gitbook.io/vale/getting-started/configuration for information about creating a config file.
      """
    And the exit status should be 0

  Scenario: Non-Existent Config
    When I test "/misc/one/two/three/four"
    Then the output should contain exactly:
      """
      """
    And the exit status should be 0


#  Scenario: Fall back to root config
#    When I test "/misc/one/two/three"
#    Then the output should contain exactly:
#      """
#      four/test.yml:1:7:docs.Spelling:Did you really mean 'foos'?
#      test.yml:1:7:docs.Spelling:Did you really mean 'foos'?
#      """
#    And the exit status should be 0

  Scenario: Ignore BasedOnStyle for formats it doesn't match
    Given a file named ".vale" with:
    """
    StylesPath = ../../styles/
    MinAlertLevel = warning

    [*.py]
    BasedOnStyles = vale

    vale.Spelling = NO
    """
    When I run vale "test.md"
    Then the output should contain exactly:
    """
    """
    And the exit status should be 0

  Scenario: Ignore syntax
    When I lint simple "test.md"
    Then the output should contain exactly:
    """
    test.md:3:1:vale.Annotations:'NOTE' left in text
    test.md:8:5:vale.Annotations:'NOTE' left in text
    test.md:18:4:vale.Annotations:'XXX' left in text
    test.md:20:9:vale.Annotations:'XXX' left in text
    test.md:29:5:vale.Annotations:'XXX' left in text
    test.md:32:1:vale.Annotations:'XXX' left in text
    test.md:34:29:vale.Annotations:'TODO' left in text
    test.md:36:3:vale.Annotations:'TODO' left in text
    test.md:36:10:vale.Annotations:'XXX' left in text
    test.md:36:16:vale.Annotations:'FIXME' left in text
    test.md:40:21:vale.Annotations:'FIXME' left in text
    test.md:44:5:vale.Annotations:'TODO' left in text
    test.md:46:3:vale.Annotations:'TODO' left in text
    """
    And the exit status should be 0

  Scenario: Specify BasedOnStyle on a per-syntax basis
    Given a file named ".vale" with:
    """
    StylesPath = ../../styles/
    MinAlertLevel = warning

    [*.md]
    BasedOnStyles = vale

    vale.Spelling = NO

    [*.py]
    BasedOnStyles = write-good
    write-good.E-Prime = NO
    """
    When I run vale "."
    Then the output should contain exactly:
    """
    test.md:1:11:vale.Editorializing:Consider removing 'very'
    test.py:1:1:write-good.ThereIs:Don't start a sentence with '# There is'
    test.py:1:37:write-good.Weasel:'Very' is a weasel word!
    """
    And the exit status should be 1

  Scenario: Disable/enable checks on a per-syntax basis
    Given a file named "_vale" with:
    """
    StylesPath = ../../styles/
    MinAlertLevel = warning

    [*.md]
    BasedOnStyles = vale

    vale.Spelling = NO

    [*.py]
    BasedOnStyles = write-good
    write-good.E-Prime = NO
    write-good.Weasel = NO
    """
    When I run vale "."
    Then the output should contain exactly:
    """
    test.md:1:11:vale.Editorializing:Consider removing 'very'
    test.py:1:1:write-good.ThereIs:Don't start a sentence with '# There is'
    """
    And the exit status should be 1

  Scenario: Overwrite BasedOnStyle on a per-syntax basis
    Given a file named "_vale" with:
    """
    StylesPath = ../../styles/
    MinAlertLevel = warning

    [*]
    BasedOnStyles = vale

    vale.Spelling = NO

    [*.py]
    BasedOnStyles = write-good
    write-good.E-Prime = NO
    """
    When I run vale "test.py"
    Then the output should contain exactly:
    """
    test.py:1:1:write-good.ThereIs:Don't start a sentence with '# There is'
    test.py:1:37:write-good.Weasel:'Very' is a weasel word!
    """
    And the exit status should be 1

  Scenario: Overwrite disabled rules on a per-syntax basis
    Given a file named "_vale" with:
    """
    StylesPath = ../../styles/
    MinAlertLevel = warning

    [*]
    BasedOnStyles = write-good
    write-good.Weasel = NO

    [*.py]
    write-good.Weasel = YES
    """
    When I run vale "test.py test.md"
    Then the output should contain exactly:
    """
    test.py:1:1:write-good.ThereIs:Don't start a sentence with '# There is'
    test.py:1:37:write-good.Weasel:'Very' is a weasel word!
    """
    And the exit status should be 1

  Scenario: Load two base styles
    Given a file named "_vale" with:
    """
    StylesPath = ../../styles/
    MinAlertLevel = warning

    [*]
    BasedOnStyles = Joblint, write-good
    write-good.E-Prime = NO
    """
    When I run vale "test.py test.md"
    Then the output should contain exactly:
    """
    test.md:1:11:write-good.Weasel:'very' is a weasel word!
    test.md:1:66:Joblint.TechTerms:Use 'JavaScript' instead of 'javascript'
    test.py:1:1:write-good.ThereIs:Don't start a sentence with '# There is'
    test.py:1:37:write-good.Weasel:'Very' is a weasel word!
    """
    And the exit status should be 1

  Scenario: Load individual rules
    Given a file named "_vale" with:
    """
    StylesPath = ../../styles/
    MinAlertLevel = warning

    [*]
    BasedOnStyles = vale
    write-good.ThereIs = YES
    demo.Spelling = YES
    """
    When I run vale "test.py"
    Then the output should contain exactly:
    """
    test.py:1:1:write-good.ThereIs:Don't start a sentence with '# There is'
    test.py:1:37:vale.Editorializing:Consider removing 'Very'
    test.py:2:55:demo.Spelling:Inconsistent spelling of 'center'
    """
    And the exit status should be 1

  Scenario: Load section with glob as name
    Given a file named "_vale" with:
    """
    StylesPath = ../../styles/
    MinAlertLevel = warning

    [*.{md,py}]
    BasedOnStyles = vale

    write-good.ThereIs = YES
    vale.Spelling = NO
    """
    When I run vale "test.py"
    Then the output should contain exactly:
    """
    test.py:1:1:write-good.ThereIs:Don't start a sentence with '# There is'
    test.py:1:37:vale.Editorializing:Consider removing 'Very'
    """
    And the exit status should be 1

  Scenario: Test a glob
    When I test glob "*.{py,cc}"
    Then the output should contain exactly:
    """
    test.cc:1:4:vale.Annotations:'XXX' left in text
    test.cc:9:6:vale.Annotations:'NOTE' left in text
    test.cc:13:6:vale.Annotations:'XXX' left in text
    test.cc:17:5:vale.Annotations:'FIXME' left in text
    test.cc:20:5:vale.Annotations:'XXX' left in text
    test.cc:23:37:vale.Annotations:'XXX' left in text
    test.py:1:3:vale.Annotations:'FIXME' left in text
    test.py:5:5:vale.Annotations:'FIXME' left in text
    test.py:11:3:vale.Annotations:'XXX' left in text
    test.py:13:16:vale.Annotations:'XXX' left in text
    test.py:14:14:vale.Annotations:'NOTE' left in text
    test.py:17:1:vale.Annotations:'NOTE' left in text
    test.py:23:1:vale.Annotations:'XXX' left in text
    test.py:28:5:vale.Annotations:'NOTE' left in text
    test.py:35:8:vale.Annotations:'NOTE' left in text
    test.py:37:5:vale.Annotations:'TODO' left in text
    """
    And the exit status should be 0

  Scenario: Test a negated glob
    When I test glob "!*.py"
    Then the output should not contain "py"
    And the exit status should be 0

  Scenario: Test another negated glob
    When I test glob "!*.{mdx,py}"
    Then the output should not contain "mdx"
    And the output should not contain "py"
    And the exit status should be 0

  Scenario: Change a built-in rule's level
    Given a file named ".vale" with:
    """
    StylesPath = ../../styles/
    MinAlertLevel = error

    [*]
    vale.Editorializing = error
    """
    When I run vale "test.md"
    Then the output should contain exactly:
    """
    test.md:1:11:vale.Editorializing:Consider removing 'very'
    """
    And the exit status should be 1

  Scenario: List Vale's config
    When I run command "dc"
    Then the output should contain:
      """
      "vale.Annotations": true
      """
    And the output should contain:
      """
      "Relative": true
      """
    And the exit status should be 0

  Scenario: Change an external rule's level
    Given a file named "_vale" with:
    """
    StylesPath = ../../styles/
    MinAlertLevel = error

    [*.{md,py}]
    write-good.Weasel = error
    """
    When I run vale "test.py"
    Then the output should contain exactly:
    """
    test.py:1:37:write-good.Weasel:'Very' is a weasel word!
    """
    And the exit status should be 1

  Scenario: Overwrite MinAlertLevel (suggestion)
    Given a file named "_vale" with:
      """
      StylesPath = ../../styles/
      MinAlertLevel = warning

      [*]
      BasedOnStyles = write-good
      """
    When I assign minAlertLevel "suggestion" "test.md"
    Then the output should contain exactly:
      """
      test.md:1:6:write-good.E-Prime:Avoid using "is"
      test.md:1:11:write-good.Weasel:'very' is a weasel word!
      """
    And the exit status should be 0

  Scenario: Overwrite MinAlertLevel (error)
    Given a file named "_vale" with:
      """
      StylesPath = ../../styles/
      MinAlertLevel = warning

      [*]
      BasedOnStyles = write-good
      """
    When I assign minAlertLevel "error" "test.md"
    Then the output should contain exactly:
      """
      """
    And the exit status should be 0

  Scenario: Don't overwrite MinAlertLevel
    Given a file named "_vale" with:
      """
      StylesPath = ../../styles/
      MinAlertLevel = warning

      [*]
      BasedOnStyles = write-good
      """
    When I run vale "test.md"
    Then the output should contain exactly:
      """
      test.md:1:11:write-good.Weasel:'very' is a weasel word!
      """
    And the exit status should be 0

  Scenario: Local overrides
    When I inherit from "../../fixtures/configs" "ini/.vale.ini"
    Then the output should contain exactly:
      """
      test.md:3:11:proselint.Very:Remove 'very'.
      test.md:3:16:Joblint.Visionary:Avoid using 'paradigm'
      test.md:5:16:Joblint.LegacyTech:Avoid using 'Cobol'
      test.md:7:7:proselint.Jargon:'agendize' is jargon.
      """
    And the exit status should be 1

  Scenario: Local overrides + projects
    When I inherit from "../../fixtures/misc/filesystem/projects" "ini/.vale.ini"
    Then the output should contain exactly:
      """
      test.md:3:16:proselint.Very:Remove 'very'.
      test.md:5:6:Vale.Terms:Use 'Vale' instead of 'vale'.
      test.md:5:11:Vale.Repetition:'is' is repeated!
      test.md:5:26:Vale.Terms:Use 'JavaScript' instead of 'Javascript'.
      """
    And the exit status should be 1
