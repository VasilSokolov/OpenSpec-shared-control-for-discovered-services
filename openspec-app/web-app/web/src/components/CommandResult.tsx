import type { CommandOutput } from "../types";

export function CommandResult({ output }: { output: CommandOutput }) {
  const ok = output.exit_code === 0;
  const cmd = output.args.length ? `${output.script} ${output.args.join(" ")}` : output.script;
  return (
    <div className={ok ? "cmd-result ok" : "cmd-result fail"}>
      <div className="cmd-head">
        <code>{cmd}</code>
        <span className="cmd-exit">exit {output.exit_code ?? "?"}</span>
      </div>
      {output.stdout && <pre className="cmd-out">{output.stdout}</pre>}
      {output.stderr && <pre className="cmd-err">{output.stderr}</pre>}
    </div>
  );
}
