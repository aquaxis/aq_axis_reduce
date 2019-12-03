set PROJECT_NAME aq_axis_reduce
set PART_NAME xc7z020clg400-1

create_project $PROJECT_NAME ./$PROJECT_NAME -part $PART_NAME -force

set FILES [list \
           ../$PROJECT_NAME/src/aq_axis_reduce.v \
           ../$PROJECT_NAME/src/aq_axils_reduce.v \
           ../$PROJECT_NAME/src/aq_calc_size.v \
           ../$PROJECT_NAME/src/aq_div24x16.v \
           ../$PROJECT_NAME/src/aq_reduce.v \
           ../$PROJECT_NAME/src/aq_ram25x16.v \
          ]

add_files -norecurse $FILES

ipx::package_project -root_dir ../../$PROJECT_NAME -vendor aquaxis.com -library aquaxis -taxonomy /UserIP

#set_property vendor aquaxis.com [ipx::current_core]
#set_property library aquaxis [ipx::current_core]
set_property core_revision 1 [ipx::current_core]

ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]

#set_property  ip_repo_paths  ../../$PROJECT_NAME [current_project]
