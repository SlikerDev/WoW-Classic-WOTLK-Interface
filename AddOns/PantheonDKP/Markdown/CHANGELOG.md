# PDKP Change Log

##v4.9.12
### Features
- Added death knights to the list of classes that PDKP supports

### Bug Fixes
- Fixed a bug where the addon would not initialize quick enough for the minimap to be rolled up.
- Fixed a bug where you could not set DKP Officer
- Fixed a bug where you could not open PDKP
- Fixed a bug where you could not receive syncs
- Fixed a bug where Death Knights were not showing up properly in the display

##v4.9.10
### Bug Fixes
- Fixed the award popup DKP amount...again.

##v4.9.9
### Bug Fixes
- Fixed a bug where DKP award popup was not giving the correct amount of DKP for Sunwell Plateau bosses.

##v4.9.8
### Features
- Added support for Sunwell Plateau bosses receiving 20 dkp per kill.

### Bug Fixes
- Made the boss dropdown raid menu be sorted by phase instead of default sorting.

## v4.9.7
### Features
- Added 90% DKP max bid text to the minimap icon tooltip
- Version bumped for phase 5

## v4.9.6
### Bug Fixes
- Fixed a bug with non raid-ready alts being counted in the shame tab that caused a nil member error.

## v4.9.5
### Features
- Added Mini-Game leaderboard (can only view if you're participating).
- Decreased chance of being shamed.

### Bug Fixes
- Removed unnecessary comm registrations.
- Removed unnecessary timed events related to auto-sync.
- Removed unnecessary negative DKP checks.

## v4.9.4
### Features
- Added a mini-game to PDKP. Enabled in the PDKP settings under the sync tab. Off by default. 
- Leaderboard to be implemented at a later date.

### Bug Fixes
- Removed auto-sync from the PDKP settings.

## v4.9.3
### Features
- Version bump for next phase

## v4.9.2
### Features
- Added setting to turn off automatic combat logging.

## v4.9.1
### Features
- Experimental: Announce Tier Token Classes when starting bids on an item
- Added setting to turn off Boss Kill Popup when you're the Master Looter (on by default).

### Bug Fixes
- Fixed "Ghost" bids from carrying over when starting a new auction.
- Turned off Hydross death check function (no longer relevant).
- Fixed a "Reinitialization" error when receiving a DKP overwrite.

## v4.8.0
### Features
- Version released for Phase 3
- Completed auctions are now temporarily saved (until reload) for later reference if necessary. This only affects Officers.
- Experimental: Announce Tier Token Classes when starting bids (Not turned on).

## v4.7.8
### Bug Fixes
- Forgot to give them the D in PrintD...

## v4.7.7
### Features
- Options tab now closes PDKP and opens the interface options properly.
- Added in Selected filter for the member table.
- Removed PUG filter.
- Removed lockouts tab.

### Bug Fixes
- Implemented a patch for the crashing bug that happened on certain hardware
- Changed some internal code defaults with Display Update interface option.
- Fixed some lag when selecting everyone in the guild.

## v4.7.5
### Features
- Added in interface option to control how fast PDKP updates the display.
- Optimized some display updates for when the addon is open.

### Bug Fixes
- Fixed CombatLogging automation.
- Fixed Slow display updates that were received when the addon was closed.
- Fixed the Hydross workaround to only run when in SSC.

## v4.7.2
### Features
- Republishing v4.6.5 Features.
- DKP Consolidation Entry added to reduce entry load.
- Prevent DKP Recalibration from occurring when in combat.
- Enabled DB Backup on Overwrite by default.

### Bug Fixes
- Republishing v4.6.5 fixes.
- Fixed DKP Award Popup for Hydross the Unstable.
- Fixed a bug where GUI tables were being updated when PDKP was closed. They will now update on next open.

## v4.6.5
### Features
- Added interface setting to allow Sync in Combat (overwrites).
- Added WagoAnalytics Library.

### Bug Fixes
- Fixed a bug with new entries causing slight frame drops.
- Fixed a bug with "new" members being reinitialized in a loop.
- Fixed a bug with single entry additions causing lag spikes.
- Fixed a bug with tables updating when the addon was closed.

## v4.6.0
### Features
- Added SyncManager to help break up where syncs are going (raid vs guild) and prevent data loss.
- Added Auto Combat Logging when entering a Raid Instance with the DKP officer set.
- Added a confirmation popup for Officers when receiving an overwrite from another officer who is not in your raid.
- Removed settings overwrite when wiping your database.
- Added an interface option to automatically back up your database when receiving an overwrite (off by default).

### Bug Fixes
- Fixed a bug with decay entries not being properly marked as deleted in the database if the deletion was interrupted.
- Fixed a bug with overwrites hitting a null database error during decay entries with members who have not raided.
- Fixed a bug where I forgot to give entries the D in deleteD. Causing deleted entries to not always be marked as such.

## v4.5.5
### Features
- Added confirmation dialog popup when max bidding through the bid interface (not whispers).
- Moved the max bid button, so that it doesn't overlap the cancel bid button anymore.
- Added an error message for when the auto-award popup fails to populate.
- Added an error message for when the boss-kill includes more people than are in the raid group.

### Bug Fixes
- Fixed a UI issue where frames duplicated when you received a DKP Overwrite causing odd behaviors during bids.
- Fixed an issue with DKP Overwrites not properly reinitializing the addon to reflect the new data.
- Fixed an issue where the "Promote to DKP Officer" portrait text reinitialized when it shouldn't during an overwrite.
- Fixed an issue with Phase Squish entries ending a merge prematurely, resulting in everyone's DKP being 0 or 30.
- Fixed an issue where Phase Squish Entries were not properly updating DKP snapshots.
- Fixed an issue with merges where Phase Entries could be sent when they shouldn't have been.
- Fixed an issue where auto-sync would be checked after a database-reset.
- Fixed an issue where boss-kill award popup wouldn't let you know it failed.

## v4.5.2
### Bug Fixes
- Fixed a multi-addon issue with LibDeflate, idk if it'll post in time.

## v4.5.1
### Bug Fixes
- Fixed an occasional error with compression_co LibDeflate library.

## v4.5.0
### Features
- Automatic Data Sync: This has been completely revamped to fix the previous lag problems. This will allow for everyone to have their tables up to date, automatically throughout the week.
- Sync Lag Prevention: This is one of the biggest features in this version, and I'm super excited for it. Syncing (merge and automatic) will take a little longer than usual, but the benefit of this, is a lag-free-sync.
- Turned on 90% max DKP Bid restriction (See discord for more info).
- Promoting DKP Officer now automatically gives them raid assistant.
- Added a "Max Bid" button to the bidding interface. The "pending bid" text will not update when you do this, but you will show up in the bid list.
- Added in Addon Interface Options (lots of cool options, check it out).
- You can hide the minimap icon (interface options).
- Sync Processing Speed Interface Option added.
- Decompression Speed Interface Option Added.
- Automatic Sync Interface Toggle Added.
- Database backup Interface Option Added.
- Database restore Interface Option Added.
- Database wipe Interface Option Added.
- Phase DKP entries (50%) will now "Squish" your database, to conserve sync disk space for future phases (faster loads, syncs, etc...).

### Bug Fixes
- Fixed "Promote Leadership" button to only promote leadership (Weird blizzard issue).
- Fixed DKP Officer buttons showing up occasionally when an error occurs for non-officer members (Thanks Shvou for pointing this out).
- Fixed Bidding Issues when in Combat.
- Fixed the "add time" button showing for officers who could not edit the auction.
- Overwrites no longer require a reload.


## v4.4.1
### Features
- Turned on Phase 2 bosses
- Turned on Phase Decay (50%) adjustment reason
- Expose chat commands for /pdkp help

### Bug Fixes
- Decay entries will not decay members who have less than 31 DKP.
- The "Load More" button now visually loads the entries correctly.
- PUG invite messages won't be filtered out by default anymore.
- Swapping the entry reason from Decay to Item Win will no longer cause a visual freak out (negative zero)
- Fixed some "Interface failed because of addon" issues... even though it's blizzard's fault, not addons...
- Incremented the Interface #

## v4.3.3
### Features
- Added Github hook to notify discord of new PDKP updates!

### Bug Fixes

- Fixed a bug where you could not start auctions from the boss loot bag while having ElvUI enabled.
- Fixed a bug where promoting leadership in the raid, would promote a bunch of people (most likely a guild permissions issue, not the addon).
- Fixed a bug where some users would receive an error when receiving a whisper due to invite_commands not being populated.

## v4.3.2

### Features (NEW)
**Whisper Commands**: You can now whisper the DKP Officer a few different commands, such as:
- `!bid 20` - To bid 20 DKP for the current item being bidded on.
- `!bid max` - To bid your **MAX** DKP on an item
- `!bid cancel` - To cancel a previous bid you've sent in.
- `!cap` - To find out what the Guild DKP Cap is, as well as the raid DKP cap.
- `!dkp` - To find out what the DKP Officer has your dkp as.

These whispers will be filtered out from their chat log, so they will never see the amount of DKP that you bid.

**Add Auction Time**: You can now add 10 seconds to an auction if you have a designated role within the raid (DKP officer, raid leader or loot master).

**Movable Sync Timer**: You can now move around the sync-timer, so it's no longer stuck at the top of the screen.

**Auto Invite Chat Filter**: Auto-invite whispers will be automatically filtered out of the receivers window.

### Bug Fixes
- Fixed a bug where syncing deleted decays were not happening correctly.
- Fixed a bug in Ace3:Serializer where table serialization was not happening the same across clients, resulting in the comparison hashes to be off, even when identical.
- Fixed a bug where the boss-kill popup was not occurring for the DKP Officer in raids where it should have been.
- Fixed a bug where the Bid window would appear when on a low-level alt.
- Fixed a visual bug where old-bids were still showing up on non-officer bid windows after a new bid was started.
- Fixed a visual bug where bids weren't being sorted from highest to lowest after bidding window finished.
- Fixed a bug where auto-invites would break occasionally when you deleted your saved variables file.
- Fixed a bug where auto-invites would not hide the "accept" window, after you were already invited to the party.
- Fixed a bug where deleting a decay entry would sometimes give people the wrong DKP amount back, lowering their previous DKP by 1 (math is dumb) in certain edge-cases.
- Fixed a bug where deleting an entry would cause those who did not have the entry to ignore the deleted entry, but accept the "corrected" version of it, resulting in a net-positive DKP-gain on their totals instead of a zero-sum difference.
- Fixed a bug where your client would lock up for 10 or so seconds when receiving a DKP `merge`, this may still occur but at a much quicker rate.
- Fixed a bug where deleting a boss kill entry would not allow you to re-apply that boss kill for members in that raid group within the same week.

### Disabled (RIP)
Auto-syncing - Auto Sync is currently disabled until lag spike issues can be resolved.

---
## v4.0.0

#### PUGS
Pugs are now able to be added to entries, and receive DKP in the database. They will not have a displayed class unfortunately, due to limitations of the WoW API for requesting this data when they are not in the group.

PUG names will be prefixed with a (P). Example: (P) Pantheonbank

This also means that members who are no longer in the guild, will also be considered PUGS in terms of the database, and will be displayed as such.

#### Members Filters
- Shaman Class Filter Added
- PUG filter added

#### History Tab
- History tab now will only display entries that are either boss kills, or other misc entries.
- Collapsed text format goes as follows:
    - Officer Name | Raid Name (if applicable) | Boss Name (if applicable) or Reason text.
- Entries that have occurred within the last 4 weeks will be displayed to mitigate lag upon logging in. You can click "Load More" to load older entries.

#### Loot Tab
- Loot tab now will only display entries that are related to item wins.
- Collapsed text format goes as follows:
    - Officer Name | Winner Name | Item Link
- Entries with linked items, can be clicked just like any other item link in game.

#### Item Bidding
When an Officer starts a new auction, you will be presented with the Bidding Window, similar to the shrouding window. This window will display your total DKP, for ease of use.

In this window, you can submit your bid, update your bid, cancel your bid, and view who the other bidders are and how much DKP they currently have, but not what their bid is.

Alternatively, if you've accidentally closed the window you can re-open the window via: `/pdkp bid`

Additionally, you can submit a bid via chat by typing `!bid yourBidAmount`. This can either be sent via a whisper, or just put in raid-chat.
These messages will automatically be filtered out of chat, so no one else will see your bid, but the addon will capture it and register it none the less. `/say` and `/yell` will not filter the message, but it will be registered.

### Officer Notes:

These are things mostly relevant for Officers, but you can read it if you want.

#### Entry Preview
- When creating new DKP entries, you'll have a realtime preview of its details.
- The preview will also let you know if the entry is valid or not, and try to help you find out why.

#### Entry Adjustments
- Adjustment Reasons
    - Boss Kill: Disables the amount input box, and sets the amount to 10, automatically.
        - Populates a nested dropdown where level 1 is the raid name, and level 2 is the boss name. Much simpler than previous iterations.
    - Item Win: Automatically makes the amount to a negative (Can't earn DKP from spending it, eh?)
        - Also populates an input box for the item name. This will automatically be populated with the item link that is currently up for auction, but can be empty or just the name of the item.
    - Other: Nothing new here. You can submit with or without a description. Preferably with though.
    
#### Raid Tools
- Ignore PUGS checkbox:
    - Checking this will ignore invite requests from people who are not in the guild. Enabled by default.
- Reformatted the icons positioning
- Added in DKP Officer icon.
- Added in Shaman class icon.

#### Item Auctioning
Item bidding can be started via the following methods:
- Holding Alt while Left clicking an item either in your bags, or in the loot bag.
- Typing `/pdkp bid ItemLink` (super reliable)
- Typing `/pdkp bid ItemName` (this one is less reliable, unless the name is exact)

Auctions will last for 10 seconds, during which time a timer will be displayed on the screen. If you are the master looter, and the DKP Officer, a popup will appear at the end of the timer, asking if you would like to loot the item to the winner.
This will also create and submit a new item-win entry for said winner. Otherwise, you'll have to loot it & then create the entry manually.

You can also manually end the bidding early, by clicking the button on the bottom of the Bidding Window.

#### DKP Decay

### Nerd Stuff
This section is mostly just for people who want to learn more about the inner workings of PDKP. If you don't care, you can just stop reading now.

#### Multiple Guilds
The database is now compatible with other guilds, factions and servers. This is done by a uniqueID database with the format of `server_faction_guild`. For example, ours is `Blaumeux_Alliance_Pantheon`.

#### Syncing
Syncing is always a tricky issue to handle without having an external master database. 

To overcome the state-management issue, on a weekly basis (starting on Tuesdays) entries from the previous week are used to create a unique hash. Instead of broadcasting all of your entry ID's, you will instead broadcast the last four weeks worth of weekly hashes. 

When another officer broadcasts their last four weeks worth of hashes, your addon will compare theirs to what you have. If your hashes do not match up, both of you will begin diving into that week's entries to find out where the discrepancy is. Once the discrepancy(s) is found, you will both broadcast whatever data the other is missing. This data will be consumed by all guildies that are currently online, to ensure that their database is also up to date.

I also made the decision to take out the deletion of entries. Entries are now marked as deleted, and will no longer show up in the database, but everyone will keep that record in their database.

#### Entry Encoding
DKP databases grow quite large when in an active raiding guild. You receive an entry for every boss kill, and every item won, every single raid.
This quickly becomes a problem because the larger your SavedVariables (database) file is, the longer your load screens will be. This is mostly due to how LUA handles memory management, but that's neither here nor there.

To overcome this issue, all entries in the database will automatically be encoded and compressed when they are created. 

To compare the difference this makes in the size of the database file, previously, a non-encoded file with 890 entries would be `1,021 KB` in size, where as the encoded entries have a size of just 238 KB.

#### Entry Decoding
Decoding entries is a very memory-intensive task. To combat this, only the entries that have occurred in the last 4 weeks are decoded from the start for history viewing purposes. This does not affect the sync hashing algorithm.
