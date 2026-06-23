import { CreateMLCEngine } from 'https://cdn.jsdelivr.net/npm/@mlc-ai/web-llm@0.2/+esm';

window.__webllm = { engine: null, loaded: false, progress: null, error: null };

window.__initWebLLM = async function () {
  try {
    window.__webllm.engine = await CreateMLCEngine('Phi-3-mini-4k-instruct-q4f16_1-MLC', {
      initProgressCallback: (p) => {
        window.__webllm.progress = p;
      },
    });
    window.__webllm.loaded = true;
    return 'ok';
  } catch (e) {
    window.__webllm.error = e.toString();
    return 'error: ' + e.toString();
  }
};

window.__chatWebLLM = async function (messagesJson) {
  if (!window.__webllm.engine) {
    return JSON.stringify({ error: 'Modelo no cargado' });
  }
  try {
    const messages = JSON.parse(messagesJson);
    const reply = await window.__webllm.engine.chat.completions.create({
      messages: messages,
      temperature: 0.2,
      max_tokens: 512,
    });
    return JSON.stringify({ response: reply.choices[0].message.content });
  } catch (e) {
    return JSON.stringify({ error: e.toString() });
  }
};

window.__getWebLLMStatus = function () {
  return JSON.stringify({
    loaded: window.__webllm.loaded,
    progress: window.__webllm.progress,
    error: window.__webllm.error,
  });
};
