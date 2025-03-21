extends Node

@warning_ignore("unused_signal")
signal generation_finished

## KEY: Entity RID, VAL: NavigationRegion RID
var findable_entities_regions_rids: Dictionary[RID, RID]
