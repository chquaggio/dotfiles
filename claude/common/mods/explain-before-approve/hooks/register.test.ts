import { expect, test } from 'claude-code/testing'

const USAGE = {
  input_tokens: 1,
  output_tokens: 1,
  cache_read_input_tokens: 0,
  cache_creation_input_tokens: 0,
}

test('an ask rule gets the explanation in its reason', async ($, on) => {
  const prompts: string[] = []
  on('tool.check', () => ({ decision: 'ask', rule: 'Bash(rm -rf *)', reason: 'core reason' }))
  on('session.cwd', () => ({ value: '/repo' }))
  on('model.complete', (_, request) => {
    prompts.push(request.prompt)
    return { value: { isAnswered: true, text: ' IRREVERSIBLE: deletes /repo/build.\n', usage: USAGE } }
  })

  const decided = await $.tool.check({ tool: 'Bash', input: { command: 'rm -rf build' } })

  expect(decided).toEqual({
    decision: 'ask',
    rule: 'Bash(rm -rf *)',
    reason: 'IRREVERSIBLE: deletes /repo/build.\n\nAsk rule: Bash(rm -rf *)',
  })
  expect(prompts).toEqual(['Working directory: /repo\n\n<command>\nrm -rf build\n</command>'])
})

test('a failed model call says so in the prompt', async ($, on) => {
  on('tool.check', () => ({ decision: 'ask', rule: 'Bash(git push*)' }))
  on('session.cwd', () => ({ value: '/repo' }))
  on('model.complete', () => ({ value: { isAnswered: false, reason: 'empty-reply', usage: USAGE } }))

  const decided = await $.tool.check({ tool: 'Bash', input: { command: 'git push' } })

  expect(decided.reason).toBe('(no explanation: empty-reply)\n\nAsk rule: Bash(git push*)')
})

test('a call no rule sends to the dialog stays unexplained', async ($, on) => {
  const cores = [
    { decision: 'allow' },
    { decision: 'deny', rule: 'Bash(git reset --hard*)' },
    { decision: 'ask' },
  ] as const
  let core: (typeof cores)[number] = cores[0]
  let modelCalls = 0
  on('tool.check', () => core)
  on('model.complete', () => {
    modelCalls += 1
    return { value: { isAnswered: true, text: 'x', usage: USAGE } }
  })

  for (core of cores) {
    expect(await $.tool.check({ tool: 'Bash', input: { command: 'ls' } })).toEqual(core)
  }
  expect(modelCalls).toBe(0)
})
