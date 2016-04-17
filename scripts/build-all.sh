#!/bin/bash

machines="ettus-e3xx-sg1 ettus-e3xx-sg3"
image_flavours="gnuradio-dev gnuradio-demo"
sdk_flavours="gnuradio-dev"
checked_deps=false

echo "Building images \"$image_flavours\" for machines \"$machines\"."
echo ""

for MACHINE in $machines; do
	export MACHINE

	if [ "$checked_deps" = false ] ; then
		echo "Checking tool dependencies..."
		if ! bitbake parted-native mtools-native dosfstools-native; then
			>&2 echo "Failed to build tools needed to run wic."
			exit 1
		fi
		checked_deps = true
		echo "success."
		echo ""
	fi
	echo "Building for $MACHINE ..."

	for FLAVOUR in $image_flavours;do
		echo "   bitbaking $FLAVOUR-image ..."
		if ! bitbake $FLAVOUR-image; then
			>&2 echo "$FLAVOUR image build failed for machine $MACHINE"
			exit 1
		fi
		echo "   success."
		echo "   "

		echo "   Cleaning up image build directory..."
		rm -rf images/$MACHINE/build || echo "   problems with cleaning up."

		echo "   Building SD card image..."
		if ! wic create ../meta-sdr/contrib/wks/sdimage-8G.wks  -e $FLAVOUR-image -o images/$MACHINE; then 
			>&2 echo "$FLAVOUR image sd card build failed for machine $MACHINE"
			exit 1
		fi
		echo "   success."
		echo "   "

		echo "   Compressing SD card image..."
		export IMAGE_NAME=`ls images/$MACHINE/build/sdimage*mmcblk.direct`
		export TARGET_NAME="images/$MACHINE/sdimage-$FLAVOUR.direct.xz"
		xz -T 4 -v $IMAGE_NAME || exit 1
		mv $IMAGE_NAME.xz $TARGET_NAME || exit 1
		echo "   success."
		echo "   Compressed image can be found under $(realpath $TARGET_NAME)."
		echo "   "

		echo "   Calculating md5sum of image..."
		md5sum "$TARGET_NAME" > "$TARGET_NAME.md5" || exit 1
		echo "   success."
		echo "   "
	done

done

for FLAVOUR in $sdk_flavours;do
	echo "Building SDK for image $FLAVOUR..."
	bitbake -c populate_sdk $FLAVOUR-image && echo "success."
done

