import { PluginBase, PluginCategory, PluginContext, PluginMetadata } from './plugin';

export interface PluginRegistry {
  register(plugin: PluginBase): void;
  unregister(pluginId: string): void;
  get(pluginId: string): PluginBase | null;
  getByCategory(category: PluginCategory): PluginBase[];
  getAll(): PluginBase[];
  initializeAll(context: PluginContext): Promise<void>;
  healthCheckAll(): Promise<PluginHealthStatus[]>;
  destroyAll(): Promise<void>;
}

export interface PluginHealthStatus {
  pluginId: string;
  healthy: boolean;
  latencyMs?: number;
  error?: string;
}

export interface PluginFilter {
  category?: PluginCategory;
  ids?: string[];
  search?: string;
}
