void drm_framebuffer_remove(struct drm_framebuffer *fb)
{
	/* ... */
	if (drm_framebuffer_read_refcount(fb) > 1) {
		if (drm_drv_uses_atomic_modeset(dev)) {
			int ret = atomic_remove_fb(fb);
			WARN(ret, "atomic remove_fb failed with %i\n", ret);
		} else
			legacy_remove_fb(fb);
	}

	drm_framebuffer_put(fb);
}
