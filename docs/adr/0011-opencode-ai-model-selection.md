# 11. Opencode AI Model Selection

Date: 2026-01-08

## Status

Accepted

## Context

When configuring opencode.ai for development assistance, there's a choice of AI models to use for different tasks. The default configuration was using Anthropic models, but we wanted to switch to OpenRouter with Qwen models for cost and performance reasons.

Unlike tools like Zed which allow configuring different models for specific tasks (inline assistance, commit messages, etc.), opencode primarily uses a primary model and a small model for different types of operations.

The key considerations for model selection are:

- Performance on coding tasks
- Speed of response
- Cost efficiency
- Resource requirements

## Decision

We chose to configure opencode.ai with the following models:

### Primary Model

- **Model**: `openrouter/qwen/qwen3-coder-32b-instruct`
- **Purpose**: Primary coding assistant for complex tasks
- **Rationale**: Specifically optimized for code-related tasks, excellent performance on coding benchmarks, 32B parameter size provides strong reasoning capabilities

### Small Model

- **Model**: `openrouter/qwen/qwen3-8b-instruct`
- **Purpose**: Lightweight tasks, faster responses
- **Rationale**: Much smaller and faster while still providing good performance, suitable for simpler tasks where full capability isn't needed

### Why Qwen3 Coder 32B?

**Pros:**

- Excellent at code generation, debugging, and explanation
- Strong reasoning capabilities
- Good for complex programming tasks
- Open-source model available through OpenRouter

**Cons:**

- Larger model requires more resources
- Slower response times than smaller models
- Higher cost per request than smaller models

### Why Qwen3 8B?

**Pros:**

- Fast response times
- Low resource requirements
- Cost-effective for simple tasks
- Still provides good performance for many use cases

**Cons:**

- Less capable than larger models
- May struggle with complex reasoning tasks
- Limited context window compared to larger models

## Comparison with Other Tools

Unlike Zed which supports task-specific model configuration (different models for inline assistance, commit messages, thread summaries, etc.), opencode currently focuses on a simpler model configuration approach with just a primary model and a small model. This approach:

**Pros:**

- Simpler configuration and management
- Consistent behavior across all operations
- Easier to troubleshoot and optimize

**Cons:**

- Less fine-tuned optimization for specific tasks
- May not be optimal for all use cases

## Opencode Model Configuration Options

Based on opencode documentation, the tool supports the following model-related configuration options:

1. **Primary Model (`model`)**: The main model used for most operations
2. **Small Model (`small_model`)**: A separate model for lightweight tasks like title generation
3. **Provider Configuration**: Options to configure specific providers with timeouts and other settings
4. **Model Variants**: Support for different variants of models with different configurations
5. **Multiple Providers**: Support for 75+ LLM providers through Models.dev

However, opencode does not currently support the level of task-specific model assignment that tools like Zed offer.

## Alternatives Considered

### Option 1: Keep Anthropic models

**Rejected** because:

- Higher cost
- Vendor lock-in concerns
- Less flexibility in model selection

### Option 2: Use OpenAI models

**Rejected** because:

- Higher cost than open-source alternatives
- Privacy concerns with sending code to OpenAI
- Similar performance to Qwen3 Coder for our use cases

### Option 3: Use other open-source models (Mistral, Llama)

**Rejected** because:

- Qwen3 Coder is specifically optimized for coding tasks
- Better performance on coding benchmarks than general-purpose models
- Good balance of capability and efficiency

### Option 4: Configure multiple models for specific tasks (like Zed)

**Rejected** because:

- Opencode doesn't currently support this level of model specialization
- Would add complexity without clear benefits
- Primary + small model approach is sufficient for our use cases

## Consequences

### Positive

- **Cost reduction** - Open-source models through OpenRouter are more cost-effective
- **Better coding performance** - Qwen3 Coder is optimized for development tasks
- **Flexibility** - Can easily switch models as better options become available
- **Privacy** - Keeping code within open-source model ecosystem
- **Simplicity** - Straightforward configuration that's easy to manage

### Negative

- **Setup complexity** - Need to configure OpenRouter API key
- **Potential reliability issues** - Depending on OpenRouter availability
- **Migration effort** - Need to update existing configurations
- **Less task-specific optimization** - Not using different models for different tasks like Zed

### Neutral

- No change in opencode.ai core functionality, only model selection
- Can be changed back if needed
- Configuration follows opencode's current architectural approach
