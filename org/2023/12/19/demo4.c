static void legacy_remove_fb(struct drm_framebuffer *fb)
{
	struct drm_device *dev = fb->dev;
	struct drm_crtc *crtc;
	struct drm_plane *plane;

	drm_modeset_lock_all(dev);
	/* remove from any CRTC */
	drm_for_each_crtc(crtc, dev) {
		if (crtc->primary->fb == fb) {
			/* should turn off the crtc */
			if (drm_crtc_force_disable(crtc))
				DRM_ERROR("failed to reset crtc %p when fb was deleted\n", crtc);
		}
	}

	drm_for_each_plane(plane, dev) {
		if (plane->fb == fb)
			drm_plane_force_disable(plane);
	}
	drm_modeset_unlock_all(dev);
}
