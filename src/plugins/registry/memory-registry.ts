import { PluginBase, PluginCategory, PluginContext } from '../interfaces/plugin';
import { PluginRegistry, PluginHealthStatus } from '../interfaces/registry';

export class MemoryPluginRegistry implements PluginRegistry {
  private plugins = new Map<string, PluginBase>();
  private context: PluginContext | null = null;

  register(plugin: PluginBase): void {
    if (this.plugins.has(plugin.metadata.id)) {
      this.log('warn', `Plugin "${plugin.metadata.id}" already registered, overwriting`, { pluginId: plugin.metadata.id });
    }
    this.plugins.set(plugin.metadata.id, plugin);
    this.log('info', `Plugin "${plugin.metadata.id}" registered`, { pluginId: plugin.metadata.id, version: plugin.metadata.version });
  }

  unregister(pluginId: string): void {
    if (!this.plugins.has(pluginId)) {
      this.log('warn', `Plugin "${pluginId}" not found for unregistration`, { pluginId });
      return;
    }
    this.plugins.delete(pluginId);
    this.log('info', `Plugin "${pluginId}" unregistered`, { pluginId });
  }

  get(pluginId: string): PluginBase | null {
    return this.plugins.get(pluginId) ?? null;
  }

  getByCategory(category: PluginCategory): PluginBase[] {
    return Array.from(this.plugins.values()).filter((p) => p.metadata.category === category);
  }

  getAll(): PluginBase[] {
    return Array.from(this.plugins.values());
  }

  async initializeAll(context: PluginContext): Promise<void> {
    this.context = context;
    const plugins = this.getAll();

    this.log('info', `Initializing ${plugins.length} plugin(s)`, { count: plugins.length });

    for (const plugin of plugins) {
      try {
        await plugin.initialize(context);
        this.log('info', `Plugin "${plugin.metadata.id}" initialized`, { pluginId: plugin.metadata.id });
      } catch (err) {
        const message = err instanceof Error ? err.message : String(err);
        this.log('error', `Plugin "${plugin.metadata.id}" failed to initialize`, {
          pluginId: plugin.metadata.id,
          error: message,
        });
      }
    }
  }

  async healthCheckAll(): Promise<PluginHealthStatus[]> {
    const plugins = this.getAll();

    const checks = plugins.map(async (plugin): Promise<PluginHealthStatus> => {
      const start = performance.now();
      try {
        const healthy = await plugin.healthCheck();
        const latencyMs = performance.now() - start;
        return { pluginId: plugin.metadata.id, healthy, latencyMs };
      } catch (err) {
        const latencyMs = performance.now() - start;
        const error = err instanceof Error ? err.message : String(err);
        this.log('error', `Health check failed for "${plugin.metadata.id}"`, { pluginId: plugin.metadata.id, error });
        return { pluginId: plugin.metadata.id, healthy: false, latencyMs, error };
      }
    });

    return Promise.all(checks);
  }

  async destroyAll(): Promise<void> {
    const plugins = this.getAll();
    this.log('info', `Destroying ${plugins.length} plugin(s)`, { count: plugins.length });

    for (const plugin of plugins) {
      try {
        await plugin.destroy();
        this.log('info', `Plugin "${plugin.metadata.id}" destroyed`, { pluginId: plugin.metadata.id });
      } catch (err) {
        const message = err instanceof Error ? err.message : String(err);
        this.log('error', `Plugin "${plugin.metadata.id}" failed to destroy`, {
          pluginId: plugin.metadata.id,
          error: message,
        });
      }
    }

    this.plugins.clear();
  }

  private log(level: 'info' | 'warn' | 'error' | 'debug', message: string, data?: Record<string, unknown>): void {
    if (!this.context?.logger) return;
    this.context.logger[level](message, data);
  }
}
