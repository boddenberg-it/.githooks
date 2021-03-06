# check if expect is available)
expect -v > /dev/null
if [ $? -gt 0 ]; then
	echo -e "${r}[WARNING]$u No expect installation found skipping interactive tests..."
else
	ensure_clean_test_setup "interactive"
	orphaned_hook pre-commit
	enabled_hook pre-push
	disabled_hook pre-rebase

    start="$(date +%s)"
	expect "$TEST_BASE/tests/_interactive.exp" "n" "$TEST_BASE" > /dev/null
	end="$(date +%s)"

    # evaluation (based on time out)
	if [ $((end-start)) -lt 15 ]; then
		success "interactive - smoke test (always no)"
	else
		failure "interactive - smoke test (always no)"
	fi
	
	start="$(date +%s)"
	expect "$TEST_BASE/tests/_interactive.exp" "y" "$TEST_BASE" > /dev/null
	end="$(date +%s)"

	# check for timeout
	if [ $((end-start)) = 30 ]; then
		success "${r}${b}[TIMEOUT]${d} ${u}interactive - answer yes to all"
	fi
	# check if orphaned pre-commit is deleted
	if [ ! -L "$BASE/$GIT_HOOK_DIR/pre-commit" ]; then
		success "interactive - delete orphaned hook"
	else
		failure "interactive - delete orphaned hook"
	fi
	# check it pre-push is disabled
	if [ ! -L "$BASE/$GIT_HOOK_DIR/pre-push" ]; then
		success "interactive - disable enabled hook"
	else
		failure "interactive - disable enabled hook"
	fi
	# check if pre-rebase is enabled
	if [ -L "$BASE/$GIT_HOOK_DIR/pre-rebase" ]; then
		success "interactive - enable disabled hook"
	else
		failure "interactive - enable disabled hook"
	fi
fi
