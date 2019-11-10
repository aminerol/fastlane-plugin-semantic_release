require 'spec_helper'

describe Fastlane::Actions::ConventionalChangelogAction do
  describe "Conventional Changelog" do
    before do
      Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::RELEASE_NEXT_VERSION] = '1.0.2'
      Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::RELEASE_ANALYZED] = true
    end

    def execute_lane_test
      Fastlane::FastFile.new.parse("lane :test do conventional_changelog end").runner.execute(:test)
    end

    def execute_lane_test_plain
      Fastlane::FastFile.new.parse("lane :test do conventional_changelog( format: 'plain' ) end").runner.execute(:test)
    end

    def execute_lane_test_slack
      Fastlane::FastFile.new.parse("lane :test do conventional_changelog( format: 'slack' ) end").runner.execute(:test)
    end

    def execute_lane_test_author
      Fastlane::FastFile.new.parse("lane :test do conventional_changelog( display_author: true ) end").runner.execute(:test)
    end

    def execute_lane_test_no_header
      Fastlane::FastFile.new.parse("lane :test do conventional_changelog( display_title: false ) end").runner.execute(:test)
    end

    def execute_lane_test_no_header_plain
      Fastlane::FastFile.new.parse("lane :test do conventional_changelog( format: 'plain', display_title: false ) end").runner.execute(:test)
    end

    def execute_lane_test_no_header_slack
      Fastlane::FastFile.new.parse("lane :test do conventional_changelog( format: 'slack', display_title: false ) end").runner.execute(:test)
    end

    def execute_lane_test_no_links
      Fastlane::FastFile.new.parse("lane :test do conventional_changelog( display_links: false ) end").runner.execute(:test)
    end

    def execute_lane_test_no_links_slack
      Fastlane::FastFile.new.parse("lane :test do conventional_changelog( format: 'slack', display_links: false ) end").runner.execute(:test)
    end

    it "should create sections in markdown format" do
      commits = [
        "docs: sub|body|long_hash|short_hash|Jiri Otahal|time",
        "fix: sub||long_hash|short_hash|Jiri Otahal|time"
      ]
      allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
      allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

      result = "# 1.0.2 (2019-05-25)\n\n### Bug fixes\n- sub ([short_hash](/long_hash))\n\n### Documentation\n- sub ([short_hash](/long_hash))"

      expect(execute_lane_test).to eq(result)
    end

    it "should create sections in plain format" do
      commits = [
        "docs: sub|body|long_hash|short_hash|Jiri Otahal|time",
        "fix: sub||long_hash|short_hash|Jiri Otahal|time"
      ]
      allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
      allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

      result = "1.0.2 (2019-05-25)\n\nBug fixes:\n- sub (/long_hash)\n\nDocumentation:\n- sub (/long_hash)"

      expect(execute_lane_test_plain).to eq(result)
    end

    it "should create sections in Slack format" do
      commits = [
        "docs: sub|body|long_hash|short_hash|Jiri Otahal|time",
        "fix: sub||long_hash|short_hash|Jiri Otahal|time"
      ]
      allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
      allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

      result = "*1.0.2 (2019-05-25)*\n\n*Bug fixes*\n- sub (</long_hash|short_hash>)\n\n*Documentation*\n- sub (</long_hash|short_hash>)"

      expect(execute_lane_test_slack).to eq(result)
    end

    it "should skip the header if display_title is false in markdown format" do
      commits = [
        "fix: sub|BREAKING CHANGE: Test|long_hash|short_hash|Jiri Otahal|time"
      ]
      allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
      allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

      result = "### Bug fixes\n- sub ([short_hash](/long_hash))\n\n### BREAKING CHANGES\n- Test ([short_hash](/long_hash))"

      expect(execute_lane_test_no_header).to eq(result)
    end

    it "should show the author if display_author is true in markdown format" do
      commits = [
        "fix: sub|BREAKING CHANGE: Test|long_hash|short_hash|Jiri Otahal|time"
      ]
      allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
      allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

      result = "# 1.0.2 (2019-05-25)\n\n### Bug fixes\n- sub ([short_hash](/long_hash)) - Jiri Otahal\n\n### BREAKING CHANGES\n- Test ([short_hash](/long_hash)) - Jiri Otahal"

      expect(execute_lane_test_author).to eq(result)
    end

    it "should skip the header if display_title is false in plain format" do
      commits = [
        "fix: sub|BREAKING CHANGE: Test|long_hash|short_hash|Jiri Otahal|time"
      ]
      allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
      allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

      result = "Bug fixes:\n- sub (/long_hash)\n\nBREAKING CHANGES:\n- Test (/long_hash)"

      expect(execute_lane_test_no_header_plain).to eq(result)
    end

    it "should skip the header if display_title is false in Slack format" do
      commits = [
        "fix: sub|BREAKING CHANGE: Test|long_hash|short_hash|Jiri Otahal|time"
      ]
      allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
      allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

      result = "*Bug fixes*\n- sub (</long_hash|short_hash>)\n\n*BREAKING CHANGES*\n- Test (</long_hash|short_hash>)"

      expect(execute_lane_test_no_header_slack).to eq(result)
    end

    it "should display a breaking change in markdown format" do
      commits = [
        "fix: sub|BREAKING CHANGE: Test|long_hash|short_hash|Jiri Otahal|time"
      ]
      allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
      allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

      result = "# 1.0.2 (2019-05-25)\n\n### Bug fixes\n- sub ([short_hash](/long_hash))\n\n### BREAKING CHANGES\n- Test ([short_hash](/long_hash))"

      expect(execute_lane_test).to eq(result)
    end

    it "should display a breaking change in Slack format" do
      commits = [
        "fix: sub|BREAKING CHANGE: Test|long_hash|short_hash|Jiri Otahal|time"
      ]
      allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
      allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

      result = "*1.0.2 (2019-05-25)*\n\n*Bug fixes*\n- sub (</long_hash|short_hash>)\n\n*BREAKING CHANGES*\n- Test (</long_hash|short_hash>)"

      expect(execute_lane_test_slack).to eq(result)
    end

    it "should display scopes in markdown format" do
      commits = [
        "fix(test): sub||long_hash|short_hash|Jiri Otahal|time"
      ]
      allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
      allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

      result = "# 1.0.2 (2019-05-25)\n\n### Bug fixes\n- **test:** sub ([short_hash](/long_hash))"

      expect(execute_lane_test).to eq(result)
    end

    it "should display scopes in Slack format" do
      commits = [
        "fix(test): sub||long_hash|short_hash|Jiri Otahal|time"
      ]
      allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
      allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

      result = "*1.0.2 (2019-05-25)*\n\n*Bug fixes*\n- *test:* sub (</long_hash|short_hash>)"

      expect(execute_lane_test_slack).to eq(result)
    end

    it "should skip merge commits in markdown format" do
      commits = [
        "Merge ...||long_hash|short_hash|Jiri Otahal|time",
        "Custom Merge...||long_hash|short_hash|Jiri Otahal|time",
        "fix(test): sub||long_hash|short_hash|Jiri Otahal|time"
      ]
      allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
      allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

      result = "# 1.0.2 (2019-05-25)\n\n### Bug fixes\n- **test:** sub ([short_hash](/long_hash))\n\n### Other work\n- Custom Merge... ([short_hash](/long_hash))"

      expect(execute_lane_test).to eq(result)
    end

    it "should skip merge commits in Slack format" do
      commits = [
        "Merge ...||long_hash|short_hash|Jiri Otahal|time",
        "Custom Merge...||long_hash|short_hash|Jiri Otahal|time",
        "fix: sub||long_hash|short_hash|Jiri Otahal|time"
      ]
      allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
      allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

      result = "*1.0.2 (2019-05-25)*\n\n*Bug fixes*\n- sub (</long_hash|short_hash>)\n\n*Other work*\n- Custom Merge... (</long_hash|short_hash>)"

      expect(execute_lane_test_slack).to eq(result)
    end

    it "should skip links if display_title is false in markdown format" do
      commits = [
        "docs: sub|body|long_hash|short_hash|Jiri Otahal|time",
        "fix: sub||long_hash|short_hash|Jiri Otahal|time"
      ]
      allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
      allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

      result = "# 1.0.2 (2019-05-25)\n\n### Bug fixes\n- sub\n\n### Documentation\n- sub"

      expect(execute_lane_test_no_links).to eq(result)
    end

    it "should skip links if display_title is false in Slack format" do
      commits = [
        "docs: sub|body|long_hash|short_hash|Jiri Otahal|time",
        "fix: sub||long_hash|short_hash|Jiri Otahal|time"
      ]
      allow(Fastlane::Actions::ConventionalChangelogAction).to receive(:get_commits_from_hash).and_return(commits)
      allow(Date).to receive(:today).and_return(Date.new(2019, 5, 25))

      result = "*1.0.2 (2019-05-25)*\n\n*Bug fixes*\n- sub\n\n*Documentation*\n- sub"

      expect(execute_lane_test_no_links_slack).to eq(result)
    end

    after do
    end
  end
end
