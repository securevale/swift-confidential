.DEFAULT_GOAL := help

.PHONY: help bash release tests

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

bash: ## Upgrade Bash to the latest version
	@./Scripts/upgrade_bash.sh

release-artifacts: ## Generate release artifacts
	@test -z "$$(git status --porcelain)" || { echo "Aborting due to uncommitted changes" >&2; exit 1; }
	@./Scripts/generate_release_artifacts.sh $(version)

release: release-artifacts ## Generate release artifacts and tag the release with given version
	@git tag $(version)
	@git push origin $(version)

tests: ## Run package tests
	@./Scripts/run_tests.sh
