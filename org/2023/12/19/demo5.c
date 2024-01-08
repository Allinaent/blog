static int __drm_mode_set_config_internal(struct drm_mode_set *set,
					  struct drm_modeset_acquire_ctx *ctx)
{
	/* ... */
	drm_for_each_crtc(tmp, crtc->dev) {
		struct drm_plane *plane = tmp->primary;

		if (plane->fb)
			drm_framebuffer_get(plane->fb);
		if (plane->old_fb)
			drm_framebuffer_put(plane->old_fb);
		plane->old_fb = NULL;
	}

	return ret;
}
