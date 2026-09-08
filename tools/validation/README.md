# Validation tool boundary

`/opsx:propose` and `/opsx:approve` run validation automatically. Users may
invoke `/opsx:validate` for an explicit report, but approval must never depend
on the user remembering a shell command.

Run the generic change-package validator first. When a design source is
declared, the agent separately captures the selected screen/node and compares
the screenshot/export with every normalized acceptance criterion. Store the
image and review under the active change's `context/evidence/` directory.

After approval, run declared repository, contract, Postman, MongoDB,
observability, security, integration, deployment, rollback, and traceability
checks. Store evidence per task.
