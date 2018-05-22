
-- class ignore_units_display_context : public display_context {
-- public:
--     ignore_units_display_context(const display_context & dc)
--         : um_()
--         , gm_(&dc.map())
--         , tm_(&dc.teams())
--         , lbls_(&dc.hidden_label_categories())
--     {
--         static unit_map empty_unit_map;
--         um_ = &empty_unit_map;
--     }
--     const unit_map & units() const { return *um_; }
--     const gamemap & map() const { return *gm_; }
--     const std::vector<team> & teams() const { return *tm_; }
--     const std::vector<std::string> & hidden_label_categories() const { return *lbls_; }

-- private:
--     const unit_map * um_;
--     const gamemap * gm_;
--     const std::vector<team> * tm_;
--     const std::vector<std::string> * lbls_;
-- };

-- class ignore_units_filter_context : public filter_context {
-- public:
--     ignore_units_filter_context(const filter_context & fc)
--         : dc_(fc.get_disp_context())
--         , tod_(&fc.get_tod_man())
--         , gd_(fc.get_game_data())
--         , lk_(fc.get_lua_kernel())
--     {}

--     const display_context & get_disp_context() const { return dc_; }
--     const tod_manager & get_tod_man() const { return *tod_; }
--     const game_data * get_game_data() const { return gd_; }
--     game_lua_kernel * get_lua_kernel() const { return lk_; }

-- private:
--     const ignore_units_display_context dc_;
--     const tod_manager * tod_;
--     const game_data * gd_;
--     game_lua_kernel * lk_;
-- };
