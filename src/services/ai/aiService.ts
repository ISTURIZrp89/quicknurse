import { InferenceSession, Tensor } from 'onnxruntime-web';
import { useAIActions } from '../hooks';

// Model configurations - using quantized models from Hugging Face
export const AI_MODELS = {
  'biomistral-7b-q4': {
    id: 'biomistral-7b-q4',
    name: 'BioMistral 7B Q4',
    repo: 'mlx-community/BioMistral-7B-GGUF',
    file: 'biomistral-7b-q4_k_m.gguf',
    size: 4_200_000_000, // ~4.2 GB
    modelType: 'llama',
    quantization: 'q4_k_m',
    contextLength: 4096,
    isPremium: false,
  },
  'meditron-7b-q4': {
    id: 'meditron-7b-q4',
    name: 'Meditron 7B Q4',
    repo: 'epfLLM/Meditron-7B-GGUF',
    file: 'meditron-7b-q4_k_m.gguf',
    size: 4_200_000_000,
    modelType: 'llama',
    quantization: 'q4_k_m',
    contextLength: 4096,
    isPremium: false,
  },
  'clinicalcamel-7b-q4': {
    id: 'clinicalcamel-7b-q4',
    name: 'ClinicalCamel 7B Q4',
    repo: 'mlx-community/ClinicalCamel-7B-GGUF',
    file: 'clinicalcamel-7b-q4_k_m.gguf',
    size: 4_200_000_000,
    modelType: 'llama',
    quantization: 'q4_k_m',
    contextLength: 4096,
    isPremium: false,
  },
};

// Simple BPE-like tokenizer for GGUF models (placeholder - in production use proper tokenizer)
class SimpleTokenizer {
  private vocab: Map<string, number> = new Map();
  private reverseVocab: Map<number, string> = new Map();
  private merges: Map<string, number> = new Map();
  
  constructor() {
    // Initialize with basic ASCII + special tokens
    this.addToken('<pad>', 0);
    this.addToken('<s>', 1);
    this.addToken('</s>', 2);
    this.addToken('<unk>', 3);
    
    // Add basic ASCII
    for (let i = 0; i < 256; i++) {
      const char = String.fromCharCode(i);
      this.addToken(char, 4 + i);
    }
    
    // Add common medical tokens
    const medicalTokens = [
      'mg', 'kg', 'ml', 'mcg', 'IU', 'mmHg', 'bpm', 'C', 'F',
      'dosis', 'paciente', 'medicamento', 'tratamiento', 'diagnóstico',
      'síntoma', 'signo', 'vital', 'presión', 'temperatura', 'frecuencia',
      'cardiaca', 'respiratoria', 'saturación', 'oxígeno', 'glucosa',
      'insulina', 'heparina', 'furosemida', 'dopamina', 'adrenalina',
      'amilorida', 'espironolactona', 'metoprolol', 'atenolol', 'enalapril',
      'losartán', 'amlodipino', 'simvastatina', 'atorvastatina', 'omeprazol',
      'paracetamol', 'ibuprofeno', 'dipirona', 'tramadol', 'morfina',
      'fentanilo', 'midazolam', 'propofol', 'ketamina', 'etomidato',
      'rocuronio', 'suxametonio', 'cisatracurio', 'vecuronio', 'atracurio',
    ];
    
    let idx = 260;
    for (const token of medicalTokens) {
      this.addToken(token, idx++);
    }
    this.nextId = idx;
  }
  
  private nextId: number = 260;
  
  private addToken(token: string, id: number) {
    this.vocab.set(token, id);
    this.reverseVocab.set(id, token);
  }
  
  encode(text: string): number[] {
    const tokens: number[] = [];
    const words = text.toLowerCase().match(/\S+/g) || [];
    
    for (const word of words) {
      if (this.vocab.has(word)) {
        tokens.push(this.vocab.get(word)!);
      } else {
        // Fallback: character-level
        for (const char of word) {
          const id = this.vocab.get(char) || 3; // <unk>
          tokens.push(id);
        }
      }
    }
    return tokens;
  }
  
  decode(tokens: number[]): string {
    return tokens.map(t => this.reverseVocab.get(t) || '').join('');
  }
  
  getVocabSize(): number {
    return this.nextId;
  }
}

export const tokenizer = new SimpleTokenizer();

// Model manager for downloading and caching models
export class ModelManager {
  private static instance: ModelManager;
  private sessions: Map<string, InferenceSession> = new Map();
  private downloadProgress: Map<string, number> = new Map();
  private modelCache: Map<string, ArrayBuffer> = new Map();
  
  static getInstance(): ModelManager {
    if (!ModelManager.instance) {
      ModelManager.instance = new ModelManager();
    }
    return ModelManager.instance;
  }
  
  async downloadModel(modelId: string, onProgress?: (progress: number) => void): Promise<ArrayBuffer> {
    const model = AI_MODELS[modelId];
    if (!model) throw new Error(`Modelo no encontrado: ${modelId}`);
    
    // Check cache first
    if (this.modelCache.has(modelId)) {
      return this.modelCache.get(modelId)!;
    }
    
    // For now, we'll use a smaller ONNX model from Hugging Face
    // In production, download the actual GGUF and convert to ONNX
    const onnxUrl = `https://huggingface.co/onnx-community/${model.repo.split('/')[1]}-ONNX/resolve/main/model.onnx`;
    
    this.downloadProgress.set(modelId, 0);
    onProgress?.(0);
    
    try {
      const response = await fetch(onnxUrl);
      if (!response.ok) {
        // Fallback: use a tiny test model
        console.warn(`Modelo ${modelId} no disponible en ONNX, usando modelo de prueba`);
        return this.createTestModel();
      }
      
      const contentLength = parseInt(response.headers.get('content-length') || '0');
      const reader = response.body?.getReader();
      const chunks: Uint8Array[] = [];
      let received = 0;
      
      while (reader) {
        const { done, value } = await reader.read();
        if (done) break;
        chunks.push(value);
        received += value.length;
        if (contentLength > 0) {
          const progress = Math.round((received / contentLength) * 100);
          this.downloadProgress.set(modelId, progress);
          onProgress?.(progress);
        }
      }
      
      const arrayBuffer = new Uint8Array(received);
      let offset = 0;
      for (const chunk of chunks) {
        arrayBuffer.set(chunk, offset);
        offset += chunk.length;
      }
      
      this.modelCache.set(modelId, arrayBuffer.buffer);
      this.downloadProgress.set(modelId, 100);
      onProgress?.(100);
      
      return arrayBuffer.buffer;
    } catch (error) {
      console.error(`Error descargando modelo ${modelId}:`, error);
      // Return test model as fallback
      return this.createTestModel();
    }
  }
  
  private createTestModel(): ArrayBuffer {
    // Create a minimal ONNX model for testing (identity function)
    // This is a placeholder - real models would be downloaded
    return new ArrayBuffer(1024);
  }
  
  async loadModel(modelId: string): Promise<InferenceSession> {
    if (this.sessions.has(modelId)) {
      return this.sessions.get(modelId)!;
    }
    
    const modelBuffer = await this.downloadModel(modelId);
    
    try {
      const session = await InferenceSession.create(modelBuffer, {
        executionProviders: ['wasm'],
        graphOptimizationLevel: 'all',
      });
      this.sessions.set(modelId, session);
      return session;
    } catch (error) {
      console.error(`Error cargando modelo ${modelId}:`, error);
      throw new Error(`No se pudo cargar el modelo ${modelId}`);
    }
  }
  
  async runInference(modelId: string, inputIds: number[]): Promise<number[]> {
    const session = await this.loadModel(modelId);
    
    try {
      // Prepare input tensor (batch=1, seq_len=inputIds.length)
      const inputTensor = new Tensor('int64', BigInt64Array.from(inputIds.map(n => BigInt(n))), [1, inputIds.length]);
      
      const feeds = { input_ids: inputTensor };
      const results = await session.run(feeds);
      
      // Get logits output
      const logits = results.logits || results.output || Object.values(results)[0];
      if (!logits) throw new Error('No output tensor found');
      
      // Get next token (argmax of last position)
      const logitsData = logits.data as Float32Array;
      const vocabSize = logits.dims[logits.dims.length - 1];
      const lastTokenLogits = logitsData.slice(-vocabSize);
      
      // Simple sampling: top-k
      const topK = 50;
      const indexed = Array.from(lastTokenLogits).map((v, i) => ({ value: v, index: i }));
      indexed.sort((a, b) => b.value - a.value);
      const topTokens = indexed.slice(0, topK);
      
      // Temperature sampling
      const temperature = 0.7;
      const probs = topTokens.map(t => Math.exp(t.value / temperature));
      const sum = probs.reduce((a, b) => a + b, 0);
      const normalized = probs.map(p => p / sum);
      
      // Sample
      let rand = Math.random();
      for (let i = 0; i < normalized.length; i++) {
        rand -= normalized[i];
        if (rand <= 0) return [topTokens[i].index];
      }
      
      return [topTokens[0].index];
    } catch (error) {
      console.error('Error en inferencia:', error);
      throw error;
    }
  }
  
  getDownloadProgress(modelId: string): number {
    return this.downloadProgress.get(modelId) || 0;
  }
  
  unloadModel(modelId: string) {
    this.sessions.delete(modelId);
  }
  
  unloadAll() {
    for (const session of this.sessions.values()) {
      session.release();
    }
    this.sessions.clear();
  }
}

export const modelManager = ModelManager.getInstance();

// Generate response using the loaded model
export async function generateResponse(
  modelId: string,
  prompt: string,
  maxTokens: number = 512,
  onToken?: (token: string) => void
): Promise<string> {
  let inputIds = tokenizer.encode(prompt);
  let fullResponse = '';
  const eosTokenId = 2; // </s>
  
  for (let i = 0; i < maxTokens; i++) {
    const nextTokens = await modelManager.runInference(modelId, inputIds);
    const nextToken = nextTokens[0];
    
    if (nextToken === eosTokenId) break;
    
    const decoded = tokenizer.decode([nextToken]);
    fullResponse += decoded;
    onToken?.(decoded);
    
    inputIds.push(nextToken);
    
    // Limit context
    if (inputIds.length > 4096) {
      inputIds = inputIds.slice(-4096);
    }
  }
  
  return fullResponse;
}

// Clinical context formatting
export function formatClinicalPrompt(
  message: string,
  context: {
    patientAge?: number;
    patientWeight?: number;
    patientGender?: string;
    vitalSigns?: Record<string, number>;
    medications?: string[];
    diagnoses?: string[];
    allergies?: string[];
    recentNotes?: string;
    category: 'general' | 'pharmacologic' | 'interaction' | 'clinicalSummary' | 'vitalInterpretation' | 'recommendation';
  }
): string {
  const systemPrompt = `Eres un asistente clínico experto. Responde de forma precisa, segura y profesional.
Siempre incluye advertencias médicas apropiadas. No des consejos que sustituyan juicio clínico.`;
  
  let contextStr = '';
  if (context.hasPatientData) {
    contextStr = `\nCONTEXTO CLÍNICO:`;
    if (context.patientAge) contextStr += `\n- Edad: ${context.patientAge} años`;
    if (context.patientWeight) contextStr += `\n- Peso: ${context.patientWeight} kg`;
    if (context.patientGender) contextStr += `\n- Género: ${context.patientGender}`;
    if (context.vitalSigns && Object.keys(context.vitalSigns).length > 0) {
      contextStr += `\n- Signos vitales: ${JSON.stringify(context.vitalSigns)}`;
    }
    if (context.medications?.length) contextStr += `\n- Medicamentos: ${context.medications.join(', ')}`;
    if (context.diagnoses?.length) contextStr += `\n- Diagnósticos: ${context.diagnoses.join(', ')}`;
    if (context.allergies?.length) contextStr += `\n- Alergias: ${context.allergies.join(', ')}`;
    if (context.recentNotes) contextStr += `\n- Notas: ${context.recentNotes}`;
  }
  
  const categoryPrompts = {
    general: '',
    pharmacologic: '\nAnaliza el medicamento solicitado: indicaciones, dosis, contraindicaciones, interacciones, efectos adversos.',
    interaction: '\nAnaliza posibles interacciones medicamentosas con el contexto clínico.',
    clinicalSummary: '\nGenera un resumen clínico estructurado del paciente.',
    vitalInterpretation: '\nInterpreta los signos vitales proporcionados e identifica anomalías.',
    recommendation: '\nProporciona recomendaciones basadas en guías clínicas actuales.',
  };
  
  return `<s>[INST] ${systemPrompt}${contextStr}\n\n${categoryPrompts[context.category]}\n\n${message} [/INST]`;
}
