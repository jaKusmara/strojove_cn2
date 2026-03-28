import React, { useMemo, useState } from 'react';
import { QueryClient, QueryClientProvider, useMutation } from '@tanstack/react-query';
import { BrainCircuit, CheckCircle2, Loader2, TriangleAlert, RotateCcw } from 'lucide-react';

const queryClient = new QueryClient();
const API_BASE_URL = 'http://127.0.0.1:8000';

const options = {
  Outlook: ['Sunny', 'Overcast', 'Rain'],
  Temperature: ['Hot', 'Mild', 'Cool'],
  Humidity: ['High', 'Normal'],
  Wind: ['Weak', 'Strong'],
};

function predictRequest(payload) {
  return fetch(`${API_BASE_URL}/predict`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  }).then(async (res) => {
    const data = await res.json().catch(() => ({}));

    if (!res.ok) {
      const detail = data?.detail;
      const message = Array.isArray(detail)
        ? detail.map((item) => item?.msg || 'Validation error').join(', ')
        : detail || 'Prediction request failed.';
      throw new Error(message);
    }

    return data;
  });
}

function cn2RuleToText(rule) {
  if (!rule) return 'No matching rule found.';
  if (rule.default) return `DEFAULT → ${rule.prediction}`;
  if (!rule.complex?.length) return `ELSE → ${rule.prediction}`;

  const conditions = rule.complex
    .map(([attribute, value]) => `${attribute} = ${value}`)
    .join(' AND ');

  return `IF ${conditions} THEN ${rule.prediction}`;
}

function SelectField({ label, value, onChange, choices }) {
  return (
    <label className="flex flex-col gap-2">
      <span className="text-sm font-semibold text-slate-700">{label}</span>
      <select
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="h-12 w-full rounded-2xl border border-slate-200 bg-white px-4 text-slate-900 outline-none transition focus:border-slate-400 focus:ring-4 focus:ring-slate-200/70"
      >
        {choices.map((choice) => (
          <option key={choice} value={choice}>
            {choice}
          </option>
        ))}
      </select>
    </label>
  );
}

function EmptyState() {
  return (
    <div className="flex min-h-[420px] items-center justify-center rounded-[2rem] border border-dashed border-slate-200 bg-slate-50/70 p-8">
      <div className="text-center">
        <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-2xl bg-white shadow-sm">
          <BrainCircuit className="h-8 w-8 text-slate-500" />
        </div>
        <h3 className="mt-5 text-2xl font-bold text-slate-900">Prediction output</h3>
        <p className="mt-2 text-sm text-slate-500">
          Po odoslaní formulára sa tu zobrazí výsledok.
        </p>
      </div>
    </div>
  );
}

function PredictionApp() {
  const initialForm = {
    Outlook: 'Sunny',
    Temperature: 'Hot',
    Humidity: 'High',
    Wind: 'Weak',
  };

  const [form, setForm] = useState(initialForm);

  const mutation = useMutation({
    mutationFn: predictRequest,
  });

  const matchedRuleText = useMemo(() => {
    return cn2RuleToText(mutation.data?.matched_rule);
  }, [mutation.data]);

  const handleFieldChange = (field, nextValue) => {
    setForm((prev) => ({ ...prev, [field]: nextValue }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    mutation.mutate(form);
  };

  const handleReset = () => {
    setForm(initialForm);
    mutation.reset();
  };

  return (
    <div className="min-h-screen bg-slate-100 text-slate-900">
      <div className="mx-auto flex min-h-screen w-full max-w-[1600px] items-center px-4 py-6 sm:px-6 lg:px-10">
        <div className="grid w-full gap-6 xl:grid-cols-2">
          <form
            onSubmit={handleSubmit}
            className="rounded-[2rem] border border-slate-200 bg-white p-6 shadow-[0_20px_60px_-24px_rgba(15,23,42,0.25)] sm:p-8"
          >
            <div className="mb-8">
              <h1 className="text-3xl font-bold tracking-tight text-slate-900 sm:text-4xl">
                Model inputs
              </h1>
            </div>

            <div className="rounded-[2rem] border border-slate-200 bg-slate-50 p-5 sm:p-6">
              <div className="grid gap-5 sm:grid-cols-2">
                <SelectField
                  label="Outlook"
                  value={form.Outlook}
                  onChange={(value) => handleFieldChange('Outlook', value)}
                  choices={options.Outlook}
                />
                <SelectField
                  label="Temperature"
                  value={form.Temperature}
                  onChange={(value) => handleFieldChange('Temperature', value)}
                  choices={options.Temperature}
                />
                <SelectField
                  label="Humidity"
                  value={form.Humidity}
                  onChange={(value) => handleFieldChange('Humidity', value)}
                  choices={options.Humidity}
                />
                <SelectField
                  label="Wind"
                  value={form.Wind}
                  onChange={(value) => handleFieldChange('Wind', value)}
                  choices={options.Wind}
                />
              </div>

              <div className="mt-6 flex flex-col gap-3 sm:flex-row">
                <button
                  type="submit"
                  disabled={mutation.isPending}
                  className="inline-flex h-12 items-center justify-center gap-2 rounded-2xl bg-slate-900 px-6 font-semibold text-white transition hover:bg-slate-800 disabled:cursor-not-allowed disabled:opacity-70"
                >
                  {mutation.isPending ? (
                    <Loader2 className="h-4 w-4 animate-spin" />
                  ) : (
                    <BrainCircuit className="h-4 w-4" />
                  )}
                  {mutation.isPending ? 'Predicting...' : 'Run prediction'}
                </button>

                <button
                  type="button"
                  onClick={handleReset}
                  className="inline-flex h-12 items-center justify-center gap-2 rounded-2xl border border-slate-200 bg-white px-6 font-semibold text-slate-700 transition hover:bg-slate-100"
                >
                  <RotateCcw className="h-4 w-4" />
                  Reset
                </button>
              </div>
            </div>
          </form>

          <section className="rounded-[2rem] border border-slate-200 bg-white p-6 shadow-[0_20px_60px_-24px_rgba(15,23,42,0.25)] sm:p-8">
            <div className="mb-8">
              <h2 className="text-3xl font-bold tracking-tight text-slate-900 sm:text-4xl">
                Prediction
              </h2>
            </div>

            {!mutation.data && !mutation.isPending && !mutation.isError && <EmptyState />}

            {mutation.isPending && (
              <div className="flex min-h-[420px] items-center justify-center rounded-[2rem] border border-slate-200 bg-slate-50 p-8">
                <div className="flex items-center gap-3 text-slate-700">
                  <Loader2 className="h-5 w-5 animate-spin" />
                  <span className="text-base font-semibold">Waiting for response...</span>
                </div>
              </div>
            )}

            {mutation.isError && (
              <div className="flex min-h-[420px] items-center justify-center rounded-[2rem] border border-rose-200 bg-rose-50 p-6 text-rose-800">
                <div className="flex max-w-lg items-start gap-3">
                  <TriangleAlert className="mt-0.5 h-5 w-5 shrink-0" />
                  <div>
                    <h3 className="font-semibold">Prediction failed</h3>
                    <p className="mt-1 text-sm leading-6">{mutation.error.message}</p>
                  </div>
                </div>
              </div>
            )}

            {mutation.data && (
              <div className="space-y-5">
                <div className="rounded-[2rem] bg-slate-900 p-7 text-white">
                  <p className="text-sm uppercase tracking-[0.22em] text-slate-300">
                    Predicted class
                  </p>
                  <div className="mt-4 flex items-center gap-3">
                    <CheckCircle2 className="h-7 w-7" />
                    <span className="text-3xl font-bold sm:text-4xl">
                      {mutation.data.prediction ?? 'N/A'}
                    </span>
                  </div>
                </div>

                <div className="rounded-[2rem] border border-slate-200 bg-slate-50 p-5">
                  <p className="text-sm font-semibold uppercase tracking-[0.18em] text-slate-500">
                    Matched rule
                  </p>

                  <div className="mt-4 rounded-2xl bg-white p-5 shadow-sm">
                    <p className="text-[15px] font-medium leading-7 text-slate-900">
                      {matchedRuleText}
                    </p>
                  </div>

                  {mutation.data.matched_rule && !mutation.data.matched_rule.default && (
                    <div className="mt-4 grid grid-cols-2 gap-3 sm:max-w-md">
                      <div className="rounded-2xl bg-white p-4 shadow-sm">
                        <span className="block text-xs uppercase tracking-[0.15em] text-slate-400">
                          Score
                        </span>
                        <span className="mt-2 block text-lg font-semibold text-slate-900">
                          {mutation.data.matched_rule.score?.toFixed?.(4) ??
                            mutation.data.matched_rule.score}
                        </span>
                      </div>

                      <div className="rounded-2xl bg-white p-4 shadow-sm">
                        <span className="block text-xs uppercase tracking-[0.15em] text-slate-400">
                          Coverage
                        </span>
                        <span className="mt-2 block text-lg font-semibold text-slate-900">
                          {mutation.data.matched_rule.coverage ?? '—'}
                        </span>
                      </div>
                    </div>
                  )}
                </div>

                <div className="rounded-[2rem] border border-slate-200 bg-slate-50 p-5">
                  <p className="text-sm font-semibold uppercase tracking-[0.18em] text-slate-500">
                    Payload
                  </p>

                  <div className="mt-4 rounded-2xl bg-slate-900 p-4 shadow-sm">
                    <pre className="overflow-x-auto text-sm leading-7 text-slate-100">
                      {JSON.stringify(mutation.data.input, null, 2)}
                    </pre>
                  </div>
                </div>
              </div>
            )}
          </section>
        </div>
      </div>
    </div>
  );
}

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <PredictionApp />
    </QueryClientProvider>
  );
}