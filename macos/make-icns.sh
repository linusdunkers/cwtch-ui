input_filepath="../cwtch.png"
output_iconset_name="cwtch.iconset"
mkdir $output_iconset_name

sips -z 16 16     $input_filepath --out "${output_iconset_name}/icon_16x16.png"
cp "${output_iconset_name}/icon_16x16.png" Runner/Assets.xcassets/AppIcon.appiconset/app_icon_16.png
sips -z 32 32     $input_filepath --out "${output_iconset_name}/icon_16x16@2x.png"
sips -z 32 32     $input_filepath --out "${output_iconset_name}/icon_32x32.png"
cp "${output_iconset_name}/icon_32x32.png" Runner/Assets.xcassets/AppIcon.appiconset/app_icon_32.png
sips -z 64 64     $input_filepath --out "${output_iconset_name}/icon_32x32@2x.png"
cp "${output_iconset_name}/icon_32x32@2x.png" Runner/Assets.xcassets/AppIcon.appiconset/app_icon_64.png
sips -z 128 128   $input_filepath --out "${output_iconset_name}/icon_128x128.png"
cp "${output_iconset_name}/icon_128x128.png" Runner/Assets.xcassets/AppIcon.appiconset/app_icon_128.png
sips -z 256 256   $input_filepath --out "${output_iconset_name}/icon_128x128@2x.png"
sips -z 256 256   $input_filepath --out "${output_iconset_name}/icon_256x256.png"
cp "${output_iconset_name}/icon_256x256.png" Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png
sips -z 512 512   $input_filepath --out "${output_iconset_name}/icon_256x256@2x.png"
sips -z 512 512   $input_filepath --out "${output_iconset_name}/icon_512x512.png"
cp "${output_iconset_name}/icon_512x512.png" Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png
sips -z 1024 1024   $input_filepath --out "${output_iconset_name}/icon_1024x1024.png"
cp "${output_iconset_name}/icon_1024x1024.png" Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png

iconutil -c icns $output_iconset_name

rm -R $output_iconset_name
