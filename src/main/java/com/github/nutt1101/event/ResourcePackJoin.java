package com.github.nutt1101.event;

import com.github.nutt1101.CatchBall;
import com.github.nutt1101.ConfigSetting;
import org.bukkit.ChatColor;
import org.bukkit.entity.Player;
import org.bukkit.event.EventHandler;
import org.bukkit.event.EventPriority;
import org.bukkit.event.Listener;
import org.bukkit.event.player.PlayerJoinEvent;
import org.bukkit.event.player.PlayerResourcePackStatusEvent;
import org.bukkit.plugin.Plugin;

import java.util.logging.Level;

/**
 * Pushes the plugin's resource pack (e.g. the Safari Net reskin) to players
 * automatically on join, as an alternative to setting `resource-pack` /
 * `resource-pack-sha1` in server.properties.
 *
 * Controlled entirely by the `ResourcePack` section of config.yml.
 */
public class ResourcePackJoin implements Listener {
    private final Plugin plugin = CatchBall.plugin;

    @EventHandler(priority = EventPriority.MONITOR)
    public void onJoin(PlayerJoinEvent event) {
        if (!ConfigSetting.resourcePackEnabled) {
            return;
        }

        byte[] hash = hexToBytes(ConfigSetting.resourcePackSha1);
        Player player = event.getPlayer();

        if (hash == null) {
            plugin.getLogger().log(Level.WARNING, ChatColor.RED
                    + "ResourcePack.sha1 in config.yml is missing or not a valid 40-character SHA-1 hash; skipping resource pack push for "
                    + player.getName() + ".");
            return;
        }

        try {
            player.setResourcePack(
                    ConfigSetting.resourcePackUrl,
                    hash,
                    ConfigSetting.resourcePackPrompt,
                    ConfigSetting.resourcePackForce
            );
        } catch (Exception e) {
            plugin.getLogger().log(Level.WARNING, ChatColor.RED
                    + "Failed to send resource pack to " + player.getName() + ": " + e.getMessage());
        }
    }

    @EventHandler
    public void onResourcePackStatus(PlayerResourcePackStatusEvent event) {
        if (!ConfigSetting.resourcePackEnabled) {
            return;
        }

        Player player = event.getPlayer();

        switch (event.getStatus()) {
            case FAILED_DOWNLOAD:
                plugin.getLogger().log(Level.WARNING, ChatColor.RED
                        + player.getName() + " failed to download the resource pack. Double-check ResourcePack.url and ResourcePack.sha1 in config.yml.");
                break;
            case DECLINED:
                if (ConfigSetting.resourcePackForce) {
                    player.kickPlayer(ConfigSetting.resourcePackPrompt);
                }
                break;
            default:
                // ACCEPTED / SUCCESSFULLY_LOADED - nothing to do
                break;
        }
    }

    /**
     * Converts a 40-character hex SHA-1 string (e.g. from `sha1sum`) to the
     * 20-byte array the Bukkit API expects. Returns null if the input isn't
     * a valid SHA-1 hash.
     */
    private byte[] hexToBytes(String hex) {
        if (hex == null) {
            return null;
        }

        String cleaned = hex.trim();
        if (cleaned.length() != 40) {
            return null;
        }

        try {
            byte[] bytes = new byte[20];
            for (int i = 0; i < 20; i++) {
                bytes[i] = (byte) Integer.parseInt(cleaned.substring(i * 2, i * 2 + 2), 16);
            }
            return bytes;
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
