from openlineage.client.run import RunEvent, RunState
from openlineage.dbt.tracer import DbtTracer
from openlineage.client.facet import ErrorMessageRunFacet

class CustomDbtTracer(DbtTracer):
    def on_dbt_run_failed(self, exc: Exception):
        # Emit a failed run event with an error message
        run_facet = {
            "errorMessage": ErrorMessageRunFacet(
                message=str(exc),
                programmingLanguage="python"
            )
        }

        self.emit(
            RunEvent(
                eventType=RunState.FAIL,
                eventTime=self._now_iso(),
                run=self.run,
                job=self.job,
                producer=self.producer,
                runFacets=run_facet
            )
        )
