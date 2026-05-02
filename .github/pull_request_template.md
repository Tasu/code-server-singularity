## Summary

- Briefly describe what this PR changes.

## Checklist

- [ ] I pushed my branch immediately before opening this PR.
- [ ] I ran local full checks at that pre-PR push timing.
- [ ] I confirmed lightweight CI checks are expected to pass.

## Local Full Check Result (required)

Run command used:

```bash
SINGULARITY_CMD="conda run -n nf-env singularity" ./scripts/local_full_check.sh
```

Record the result from the run executed at the latest push before opening this PR:

- Date/time (local):
- Branch:
- Commit SHA (short):
- Result: PASS / FAIL
- Notes (optional):

## Operator Note (important)

- Do not upload log files to the repository.
- Add a short result summary in this PR body.
- If needed, also add an additional PR comment with the same summary.
- Default pre-push mode is full. If smart mode is used for this PR, state that in Notes.

## Testing Scope

- [ ] build_sif.sh
- [ ] test_sif.sh
- [ ] local_full_check.sh
- [ ] ci_check.sh