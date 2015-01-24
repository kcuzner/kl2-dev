/**
 * Mid-level startup routine for MKL26Z
 * Kevin Cuzner
 */

#include "common.h"

void startup(void)
{
    main();
    while(1) {}
}
